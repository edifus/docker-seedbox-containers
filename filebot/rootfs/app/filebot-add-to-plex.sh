#!/usr/bin/with-contenv bash

usage() {
  cat << EOF
  usage: $0 options

  OPTIONS:
    -h    Show this message
    -m    Mode to run script (test/hardlink)
EOF
}

while getopts ":h:m:t:" OPTION; do
  case ${OPTION} in
    h)
      usage
      exit 1
      ;;
    m)
      _FILEBOT_MODE=${OPTARG}
      ;;
    t)
      _PLEX_TOKEN=${OPTARG}
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

FILEBOT_BASE=/config
FILEBOT_LOG=${FILEBOT_BASE}/logs/filebot.amc.${_FILEBOT_MODE}.log
FILEBOT_EXCLUDE=${FILEBOT_BASE}/logs/filebot.exclude.log
MOVIE_FORMAT=${FILEBOT_BASE}/formats/moviesFormat.groovy
SERIES_FORMAT=${FILEBOT_BASE}/formats/seriesFormat.groovy
ANIME_FORMAT=${FILEBOT_BASE}/formats/animeFormat.groovy

OUTPUT_FOLDER=

if [[ ${_FILEBOT_MODE} != "test" ]] && [[ ${_FILEBOT_MODE} != "hardlink" ]]; then
  echo "script must be run in test mode or hardlink mode"
  exit 1
fi

if [[ ${WATCHDIR} =~ "movies" ]]; then
  FILEBOT_LABEL="Movies"
  if [[ ${WATCHDIR} =~ "movies-4k" ]]; then
    LIBRARY_INDEX=6
    OUTPUT_FOLDER=/seedbox/media/videos/movies-4k
  elif [[ ${WATCHDIR} =~ "movies-hdr" ]]; then
    LIBRARY_INDEX=2
    OUTPUT_FOLDER=/seedbox/media/videos/movies-hdr
  else
    LIBRARY_INDEX=2
    OUTPUT_FOLDER=/seedbox/media/videos/movies
  fi
elif [[ ${WATCHDIR} =~ "tv" ]]; then
  FILEBOT_LABEL="Series"
  if [[ ${WATCHDIR} =~ "tv-4k" ]]; then
    LIBRARY_INDEX=7
    OUTPUT_FOLDER=/seedbox/media/videos/tv-4k
  else
    LIBRARY_INDEX=3
    OUTPUT_FOLDER=/seedbox/media/videos/tv
  fi
elif [[ ${WATCHDIR} =~ "anime" ]]; then
  FILEBOT_LABEL="Anime"
  LIBRARY_INDEX=1
  OUTPUT_FOLDER=/seedbox/media/videos/anime
fi

echo "$(date +%Y-%m-%dT%H:%M:%S) | $0 $*"
#echo "mode:   ${_FILEBOT_MODE}"
#echo "source: ${WATCHDIR}"
#echo "target: ${OUTPUT_FOLDER}"
#echo "label:  ${FILEBOT_LABEL}"
#echo "plex:   ${LIBRARY_INDEX}"

# script can only be triggered once every X seconds
sleep 5

s6-setuidgid abc \
  find "${WATCHDIR}" -type f \( -iname '*.mkv' -o -iname '*.mp4' -o -iname '*.avi' \) -not -iname '*sample*' -links 1 \
    -exec filebot -script fn:amc -r -non-strict \
    --action "${_FILEBOT_MODE}" \
    --conflict override \
    --output ${OUTPUT_FOLDER} \
    --log-file ${FILEBOT_LOG} \
    --def artwork=n \
          extras=n \
          skipExtract=y \
          unsorted=n \
          ut_label=${FILEBOT_LABEL} \
          excludeList=${FILEBOT_EXCLUDE} \
          movieFormat=@${MOVIE_FORMAT} \
          seriesFormat=@${SERIES_FORMAT} \
          animeFormat=@${ANIME_FORMAT} \
    {} +

# update plex libraries
if [[ "${_FILEBOT_MODE}" != "test" ]]; then
  if [ -z "${_PLEX_TOKEN+x}" ]; then
    curl http://plex:32400/library/sections/${LIBRARY_INDEX}/refresh?X-Plex-Token=${_PLEX_TOKEN}
  fi
fi
