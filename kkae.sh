#!/usr/bin/bash
kkae_version='v1.0'

# Debugging function
debug_message () {
if [[ ${debug} == 'true' ]] ; then
  echo "${@}"
fi
}

# Determine the display server used
if [[ "${XDG_SESSION_TYPE}" == "wayland" ]] ; then
  clipboard_manager='wl-copy'
elif [[ "${XDG_SESSION_TYPE}" == "x11" ]] ; then
  clipboard_manager='xclip'
fi

# Make sure all dependencies are met
for dependency in tr fold sort head cat ${clipboard_manager} ; do
  which ${dependency} &> /dev/null
  if [[ ${?} -ne 0 ]] ; then
    printf "Missing dependency: ${dependency}.\n" >&2
    exit 1
  fi
done

# Declare the usage function
usage() {
cat << EOF
usage: ${0} [-asmdpwbvh] [-l LENGTH] [-c CASE] [-e LIST]
Generate a random password and save it into the clipboard.
  -l LENGTH  Character length of the password (default is ${password_length}).
  -c CASE    Only include lowercase or uppercase letters.
  -a         Only include alphanumerical characters.
  -s         Include normally ignored similar characters (${similar_characters}).
  -e 'LIST'  String (in single quotes) or file with excluded characters.
  -m         Save the password into the middle-click clipboard.
  -d         Do not send a notification when the password has been saved.
  -p         Print the password instead of saving it into the clipboard.
  -w         Print the list of currently included characters and exit.
  -b         Enable debug mode.
  -v         Print the version number and exit.
  -h         Print these instructions and exit.
EOF
}

# Declare the global variables
password_length='16'
maximum_password_length='256'
password_case='both' # valid values: lowercase, uppercase, both
tr_character_set='[:graph:]' # man tr to see available options
similar_characters="0oO1lI\"'"
excluded_characters=''
middle_click_clipboard='false'
do_not_notify='false'
countdown='5' # how long to wait in seconds for a valid password to be generated before giving up
debug='false'
# If /etc/kkae.conf exists, overwrite the variables
if [[ -f /etc/kkae.conf ]] ; then
  source /etc/kkae.conf
fi

# Parse the options
while getopts l:c:ase:mdpwbvh option ; do
  case ${option} in
    l) password_length=${OPTARG}
       valid_number='^[0-9]+$'
       if ! [[ ${password_length} =~ ${valid_number} ]] ||\
       [[ ${password_length} -lt 0 ]] ||\
       [[ ${password_length} -gt ${maximum_password_length} ]]
       then
         printf "Option -l requires a number between 0 and ${maximum_password_length}.\nEdit /etc/kkae.conf to change the maximum password length.\n" >&2
         exit 1
       fi ;;
    c) password_case=${OPTARG}
       if [[ ${password_case} == 'lowercase' ]] ; then
         excluded_letters='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
       elif [[ ${password_case} == 'uppercase' ]] ; then
         excluded_letters='abcdefghijklmnopqrstuvwxyz'
       else
         printf "Option -c accepts the following paramaters: lowercase, uppercase.\n" >&2
         exit 1
       fi
       ;;
    a) tr_character_set='[:alnum:]' ;;
    s) similar_characters='' ;;
    e) if [[ -f ${OPTARG} ]] ; then
         excluded_characters=$(cat "${OPTARG}")
         if [[ $(wc -l "${excluded_characters}") -gt 1 ]] ; then
           printf "The exclusion list must be a single line.\n" >&2
           exit 1
         fi
       else
         excluded_characters="${OPTARG}"
       fi
       ;;
    m) middle_click_clipboard='true' ;;
    d) do_not_notify='true' ;;
    p) print_password='true' ;;
    w) which_characters='true' ;;
    b) debug='true' ;;
    v) printf "${kkae_version}\n" && exit 0 ;;
    h) usage && exit 0 ;;
    *) usage && exit 1 ;;
  esac
done

# Clear the options parsed by getopts
shift $(( ${OPTIND} - 1 ))

# Exit in case an invalid option has been entered
if [[ ${#} -gt 0 ]] ; then
  printf "Invalid option or parameter.\n" >&2
  usage
  exit 1
fi

debug_message "Display server detected: ${XDG_SESSION_TYPE}"

# Valid characters
valid_characters=$(tr -dc ${tr_character_set} < /dev/urandom | tr -d "${excluded_characters}${similar_characters}${excluded_letters}" | head -c 10000 | fold -w1 | sort -u | tr -d '\n')
debug_message "Valid characters: ${valid_characters}"
valid_special_characters=$(echo "${valid_characters}" | tr -d [:alnum:] | head -c 10000 | fold -w1 | sort -u | tr -d '\n')
debug_message "Valid special characters: ${valid_special_characters}"

# Print which characters are included with the current settings
if [[ ${which_characters} = 'true' ]] ; then
  echo "${valid_characters}"
  exit 0
fi

# Create the password generation function
generate_password () {
  password=$(tr -dc ${tr_character_set} < /dev/urandom | tr -d "${excluded_characters}${similar_characters}${excluded_letters}" | head -c ${password_length})
}

debug_message "Preparing to generate the password…"
# Pass a non-zero diversity target to trigger the while loop
password_diversity_target='1'
# Generate passwords until at least one character of each selected category is found in a single password
while [[ ${password_diversity} -ne ${password_diversity_target} ]] ; do
  timeout () {
    printf "Could not generate a valid password after ${countdown}s.\nTry again, or review your parameters.\nEdit /etc/kkae.conf to increase the timeout.\n" >&2
    if [[ ${do_not_notify} == 'false' ]] ; then
      notify-send -t 1000 -i dialog-password-symbolic kkae "Could not generate a valid password in time."
    fi
    exit 2
  }
  # Quit the program if a valid password could not be generated before the ${countdown}
  (( ${SECONDS} < ${countdown} )) || timeout
  generate_password
  # Reset the password diversity target on each new pass
  password_diversity_target='0'
  # Check if the password should contain at least one number
  if [[ "${valid_characters}" == *[0-9]* ]] ; then
    password_diversity_target=$(( ${password_diversity_target} + 1 ))
  fi
  # Check if the password should contain at least one lowercase letter
  if [[ "${valid_characters}" == *[a-z]* ]] ; then
    password_diversity_target=$(( ${password_diversity_target} + 1 ))
  fi
  # Check if the password should contain at least one uppercase letter
  if [[ "${valid_characters}" == *[A-Z]* ]] ; then
    password_diversity_target=$(( ${password_diversity_target} + 1 ))
  fi
  # Check if the password should contain at least one special character
  if [[ "${#valid_special_characters}" -gt 0 ]] ; then
    password_diversity_target=$(( ${password_diversity_target} + 1 ))
  fi
  
  # Reset the password diversity on each new pass
  password_diversity='0'
  # Create a function to record the diversity of the generated password
  record_diversity () {
  password_diversity=$(( ${password_diversity} + 1 ))
  }
  # Check if the password contains at least one number
  if [[ "${password}" == *[0-9]* ]] ; then
    record_diversity
  fi
  # Check if the password contains at least one lowercase letter
  if [[ "${password}" == *[a-z]* ]] ; then
    record_diversity
  fi
  # Check if the password contains at least one uppercase letter
  if [[ "${password}" == *[A-Z]* ]] ; then
    record_diversity
  fi
  # Check if the password contains at least one special character
  special_characters_in_password=$(echo "${password}" | tr -d '[a-zA-Z0-9]\n')
  if [[ "${#special_characters_in_password}" -gt 0 ]] ; then
    record_diversity
  fi
done
debug_message "Password generated: ${password}"

# Print the password and exit if asked to
if [[ ${print_password} = 'true' ]] ; then
  echo "${password}"
  debug_message "Printing password:"
  exit 0
fi

# Save the password to the clipboard
case ${XDG_SESSION_TYPE} in
  wayland)  if [[ ${middle_click_clipboard} = 'true' ]] ; then
              debug_message "Saving the password into the middle-click clipboard."
              selection='--primary'
            fi
              echo "${password}" | wl-copy --trim-newline ${selection}
              debug_message "Password copied into the Wayland clipboard." ;;
  x11)      if [[ ${middle_click_clipboard} = 'true' ]] ; then
              debug_message "Saving the password into the middle-click clipboard."
              selection='primary'
            else
              selection='clipboard'
            fi
            echo "${password}" | xclip -rmlastnl -selection ${selection}
            debug_message "Password copied into the X11 clipboard." ;;
  *)        if [[ ${middle_click_clipboard} = 'true' ]] ; then
              printf "Error: middle-click clipboard not available in WSL.\n" >&2
              exit 1
            fi
            echo "${password}" | tr -d '\n$' | clip.exe
            debug_message "Password copied into the Windows clipboard." ;;
esac

# Notify (or not) that a new password has been saved into the clipboard
if [[ ${do_not_notify} == 'true' ]] ; then
  debug_message "Do not send a notification."
  exit 0
else
  notify-send -t 1000 -i dialog-password-symbolic kkae "New random password saved in the clipboard."
  debug_message "Notification sent. Exit code: ${?}"
  exit 0
fi
