#!/bin/bash

# Author: Aleksandar Stoykovski <bavarien362@protonmail.com>

# Description
# last_pass_change.sh shows the number of days when user password was changed.
# If a user password was not changed >=90 days the script will report
# the following:
# date=2015-12-11;time=10-14;User=testuser;action=expired;lastChange=122d
# If password  is about to expire, the last 9 days (80-89) will report:
# date=2015-12-11;time=10-14;User=testuser;action=will_expired;lastChage=87d

# !!! Tested on Rhel 6,7 and Sles >= 10.4
# Some issues with Ubuntu

function initial_check() {
  if [[ ${UID} -ne 0 ]]; then
    echo "Only root can run this script." >&2
    exit 1
  fi
}

# I use passwd as it is found in most of the Linux distros.
# end result is username and password.
function user_time() {
  for user in $(cat /etc/passwd | cut -d ":" -f1); do
   passwd -S "${user}"  \
    | awk '/P/ {print $1 " " $3}'
  done
}

# main function
# user() function and is called and while loop is used
# to get the arguments time_stamp and user for further processing.
# Variables:
#   GLOBAL:
#     NONE
#   LOCAL:
#     ${today}
#     ${date}
#     ${time}
#     ${hostname}
#     ${line}
#     ${user}
#     ${time_stamp}
#     ${days}
function main() {
  # initial check, script should be run by root
  initial_check

  # Take the output from user_time function and find the number of days when
  # password was changed.
  local today="$(date +%s)"
  local date=$(date +"%Y-%m-%d" )
  local time=$(date +"%H-%M")
  local hostname=$(hostname)

  #user_time | while read line; do
  while read line; do
    local line="(${line})"
    local time_stamp="${line[1]}"
    local user="${line[0]}"
    local days="$(echo $(( $((${today} - $(date -d "${time_stamp}" +%s))) / 86400 )))"
    # echo ${time}
    echo "hostname="${hostname}";"user:" $(grep ^${user} /etc/passwd)"
    if (( "${days}" >= 80 && "${days}" <= 89 )); then
      echo "hostname="${hostname}";date="${date}";""time="${time}";""User="${user}";action=will_expire;lastChange="${days}"d"
    elif (( ${days} >=90 )); then
      echo "hostname="${hostname}";date="${date}";""time="${time}";""User="${user}";action=expired;lastChange="${days}"d"
    fi
  
  done < <(user_time)
  #done
}

main "${@}"