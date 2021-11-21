#!/usr/bin/with-contenv bash

_WATCH_DIR="${1}"
_LOCAL_DATA="${2}"
_FILEBOT_MODE="${3}"
_PLEX_TOKEN="${4}"

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

if [[ ${_WATCH_DIR} =~ "movies" ]]; then
  FILEBOT_LABEL="Movies"
  if [[ ${_WATCH_DIR} =~ "movies-4k" ]]; then
    LIBRARY_INDEX=6
    OUTPUT_FOLDER="${_LOCAL_DATA}/videos/movies-4k"
  elif [[ ${_WATCH_DIR} =~ "movies-hdr" ]]; then
    LIBRARY_INDEX=2
    OUTPUT_FOLDER="${_LOCAL_DATA}/videos/movies-hdr"
  else
    LIBRARY_INDEX=2
    OUTPUT_FOLDER=${_LOCAL_DATA}/videos/movies
  fi
elif [[ ${_WATCH_DIR} =~ "tv" ]]; then
  FILEBOT_LABEL="Series"
  if [[ ${_WATCH_DIR} =~ "tv-4k" ]]; then
    LIBRARY_INDEX=7
    OUTPUT_FOLDER="${_LOCAL_DATA}/videos/tv-4k"
  else
    LIBRARY_INDEX=3
    OUTPUT_FOLDER="${_LOCAL_DATA}/videos/tv"
  fi
elif [[ ${_WATCH_DIR} =~ "anime" ]]; then
  FILEBOT_LABEL="Anime"
  LIBRARY_INDEX=1
  OUTPUT_FOLDER="${_LOCAL_DATA}/videos/anime"
fi

echo "$(date +%Y-%m-%dT%H:%M:%S) | $0 $*"
#echo "mode:   ${_FILEBOT_MODE}"
#echo "source: ${_WATCH_DIR}"
#echo "target: ${OUTPUT_FOLDER}"
#echo "label:  ${FILEBOT_LABEL}"
#echo "plex:   ${LIBRARY_INDEX}"

find "${_WATCH_DIR}" -type f \( -iname '*.mkv' -o -iname '*.mp4' -o -iname '*.avi' \) -not -iname '*sample*' -links 1 \
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
  echo "updating plex library - curl http://plex:32400/library/sections/${LIBRARY_INDEX}/refresh?X-Plex-Token=${_PLEX_TOKEN}"
  curl http://plex:32400/library/sections/${LIBRARY_INDEX}/refresh?X-Plex-Token=${_PLEX_TOKEN}
fi

echo
echo "**** filebot run complete ****"
echo
