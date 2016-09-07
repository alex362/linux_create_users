#!/bin/bash

# Author: Aleksandar Stoykovski <bavarien362@protonmail.ch>.
# Create users from file.
# File format is as follows: 
# 1:user1:group1:user one:/bin/bash
# 2:user1:group2,group3


# Display basic usage. 
function usage() {
  cat << EOF
    $(echo -e "\n usage: ./$(basename $0) first_argument
    
    first_argument = File with users to create.
    e.g ./create_users.sh /tmp/users_list" >&2 )
EOF
  exit 1
}

function initial_check() {
  # Creating file system requires to have super user privileges.
  if [[ "${UID}" -ne 0 ]]; then
    usage
  fi

  # Check number of provided arguments.
  if [[ "${#}" -ne 1 ]]; then
    usage 
  fi

}

# Used for better formating in different tasks. 
function divider() { 
  local divider_type="=======================" 
  local divider_type="$divider_type$divider_type" 
  local divider_width="40" 
  printf "%${divider_width}.${divider_width}s\n" "${divider_type}" 
  printf "%s\n" "${1}" 
  printf "%${divider_width}.${divider_width}s\n" "${divider_type}" 
} 

function create_users() {
  local user_list="${1}"
  # Check proper formating and if file exist.
  cat ${user_list}  | grep -qP  '^[1-2]:.*:'
  if [[ "${?}" -ne 0 || ! -f ${user_list} ]]; then
    cat << EOF 
      $( echo -e "\n File should have fields in the following format:
 
    1:user1:group1:user one:/bin/bash
    2:user1:group2,group3

    In order to be properly parsed the following rules apply:
    If user belongs only to one group (primary) number 1  needs to be put on 
    front followed by  the “username” the “group”, “comment” and “shell”.

    If the user is part in more than one group number 2  needs to be put on 
    front followed by the “username” and the “group” separated by comma". >&2 )
EOF
    exit 1
  fi
  divider "Creating user and group from list"
  echo "----Creating groups----"
  for group in $(cat "${user_list}" | awk -F ":" '/^1/ {print $3}'); do
    echo "${group}"
    groupadd ${group}
  done
  echo
  if [[ "${?}" -ne 0 ]]; then
  	echo "Something went wrong, manual check needed." >&2
  	exit 1
  fi

  echo "---Creating users and setting up password---"
  IFS=":"
  while read number user group gecko shell; do
    echo
    echo "Create user:"
    echo "${user}"
    useradd -m "${user}" -g "${group}" -c '"${gecko}"' -s "${shell}"
    echo
    #echo "U10rand0mpa$$wd!" | passwd --stdin "${user}"
    echo ${user}:U10rand0mpa$$wds | chpasswd
    echo
   	passwd -e "${user}"
    echo
  done < <(cat ${user_list} | grep ^1)
  if [[ "${?}" -ne 0 ]]; then
    echo "Something went wrong, manual check needed." >&2
    exit 1
  fi

  echo "---Adding users to secondary groups---"
   while read group user; do
     echo ""${user}" >>> "${group}""
     usermod -G "${group}" "${user}"
  done < <(cat ${user_list} |  awk -F ":" '/^2/ {print $3 ":" $2}')
  if [[ "${?}" -ne 0 ]]; then
    echo "Something went wrong, manual check needed." >&2
    exit 1
  fi
 
}

# Main function is used for calling functions 
function main() { 
  # Log stdout and stderr.
  exec > >(tee /tmp/create_users_$(date +%Y-%m-%d_%H-%M-%S).log)
  exec 2>&1 

  # Script must be run with super user privileges 
  initial_check "${@}"
 
  # Create users
  create_users "${1}"
 
} 
 
main "$@"
