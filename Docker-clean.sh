#!/bin/bash
# Clean up docker.

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
GREY='\033[1;37m'
NC='\033[0m' # No Color

# The logs directory, if it does not exists create it.
DIR="logs"
if
  [ ! -d "$DIR" ]

then
  mkdir -p "$DIR" && chmod -R 755 "$DIR"
fi

DATE=$(date +"%Y-%m-%dT%H:%M:%S")

# Output all console log info to a logfile in the logs folder.
exec > >(tee -i logs/"$DATE"-image-build.log)
exec 2>&1

echo -e "${GREEN}=================================================================="
echo -e "=========== INFO: THE COMPLETE LIST OF DOCKER ENTRIES: ==========="
echo -e "=================================================================="
docker images -a
docker ps -a
docker volume ls -f dangling=true
docker volume ls
echo

# End script or continue with full clean-up.
echo -e "${RED}=================================================================="
echo -e "===== WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! ======"
echo -e "=================================================================="
echo -e " Enter [ YES or yes ] if you want to remove everything from Docker"
echo -e " all networks, all volumes, all images and all build cache!!"
echo -e "==================================================================${NC}"

# Let the script wait for user input.
exec 0</dev/tty
read -t 10 -r answer

if [ "$answer" != "${answer#[YESyes]}" ]; then

  docker image prune -a -f
  echo -e "${GREEN}=================================================================="
  echo -e "============== INFO: ALL NON-ACTIVE IMAGES REMOVED: =============="
  echo -e "==================================================================${NC}"
  echo

  docker ps -a
  docker stop $(docker ps -a -q)
  docker rm $(docker ps -a -q)
  echo -e "${GREEN}=================================================================="
  echo -e "================ INFO: STOP AND REMOVE CONTAINERS ================"
  echo -e "==================================================================${NC}"

  docker rmi $(docker images -a -q)
  echo -e "${GREEN}=================================================================="
  echo -e "================ INFO: REMOVE ALL OTHER IMAGES ================"
  echo -e "==================================================================${NC}"

  docker system prune -a --volumes -f
  echo -e "${GREEN}=================================================================="
  echo -e "==== INFO: REMOVED ALL STOPPED CONTAINERS, ======================="
  echo -e "==== ALL NETWORKS, ALL VOLUMES, ALL IMAGES, ALL BUILD CACHE!! ===="
  echo -e "==================================================================${NC}"

  # Exit script after 5 seconds.
  sleep 5
  kill -15 $PPID

else
  echo
  echo -e "${GREEN}=================================================================="
  echo -e " INFO: YOU SKIPPED A PART OF THE DOCKER CLEAN-UP! "
  echo -e " SOME STOPPED CONTAINERS, NETWORKS, "
  echo -e " VOLUMES, IMAGES AND BUILD CACHE CAN STILL BE PRESENT! "
  echo -e "==================================================================${NC}"
  echo
fi
exec 0</dev/tty
