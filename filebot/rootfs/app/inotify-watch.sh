#!/usr/bin/with-contenv bash
# (c) Wolfgang Ziegler // fago
#
# Inotify script to trigger a command on file changes.
#
# The script triggers the command as soon as a file event occurs. Events
# occurring during command execution are aggregated and trigger a single command
# execution only.
#

if [ ! -d ${WATCHDIR} ]; then
  echo "**** \$WATCHDIR environment variable not set. Exiting. ****"
  exit 1
fi

######### Configuration #########

EVENTS="close_write,moved_to"
COMMAND="exec s6-setuidgid abc /bin/bash /app/filebot-add-to-plex.sh -m hardlink"

[[ ${WATCHDIR} != */ ]] && WATCHDIR="${WATCHDIR}/"

## Exclude Git and temporary files from PHPstorm from watching.
EXCLUDE='(\.md5|\.nfo)'
INCLUDE='(\.mkv)'

##################################

##
## Setup pipes. For usage with read we need to assign them to file descriptors.
##
RUN=$(mktemp -u)
mkfifo "${RUN}"
exec 3<>"${RUN}"

RESULT=$(mktemp -u)
mkfifo "${RESULT}"
exec 4<>"${RESULT}"

clean_up () {
  ## Cleanup pipes.
  rm "${RUN}"
  rm "${RESULT}"
}

## Execute "clean_up" on exit.
trap "clean_up" EXIT


echo "$(date +%Y-%m-%dT%H:%M:%S) - Monitoring:   '${WATCHDIR}'"
echo "                    -Filebot Mode: '${FILEBOT_MODE}'"

##
## Run inotifywait in a loop that is not blocked on command execution and ignore
## irrelevant events.
##
inotifywait -m -q -r -e ${EVENTS} --exclude ${EXCLUDE} --format '%w %f %e' "${WATCHDIR}" | \
  while read -r dir filename event
  do

    # output detected events when triggered
    echo [CHANGE] [EVENT: "${event}"] [BASE DIR: "${dir}"] [NEW: "${filename}"]

    ## Clear $PID if the last command has finished.
    if [ -n "${PID}" ] && ( ! ps -p "${PID}" > /dev/null ); then
      PID=""
    fi

    ## If no command is being executed, execute one.
    ## Else, wait for the command to finish and then execute again.
    if [ -z "${PID}" ]; then
      ## Execute the following as background process.
      ## It runs the command once and repeats if we tell him so.
          (${COMMAND}; while read -r -t0.001 -u3 LINE; do
            echo running >&4
            ${COMMAND}
          done)&

      PID=$!
      WAITING=0
    else
      ## If a previous waiting command has been executed, reset the variable.
      if [ ${WAITING} -eq 1 ] && read -r -t0.001 -u4; then
        WAITING=0
      fi

      ## Tell the subprocess to execute the command again if it is not waiting
      ## for repeated execution already.
      if [ ${WAITING} -eq 0 ]; then
        echo "run" >&3
        WAITING=1
      fi

      ## If we are already waiting, there is nothing todo.
    fi
done
