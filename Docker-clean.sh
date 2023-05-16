#!/bin/bash
# clean up docker

# logs dir if it does not exists create it
DIR="logs"
if
  [ ! -d "$DIR" ]

then
  mkdir -p "$DIR" && chmod -R 755 "$DIR"
fi

DATE=$(date +"%Y-%m-%dT%H:%M:%S")

# output all console log info to a logfile in the logs folder
exec > >(tee -i logs/"$DATE"-image-build.log)
exec 2>&1

echo "complete list of docker entries:"
docker images -a
docker ps -a
docker volume ls -f dangling=true
docker volume ls

# end process or continue
echo "=================================================================="
echo "===== WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! ======"
echo "=================================================================="
echo " Enter [ YES or yes ] if you want to remove everything from Docker"
echo " all networks, all volumes, all images and all build cache"
echo "=================================================================="

# let the script wait for user input
exec 0</dev/tty
read -t 10 -r answer

if [ "$answer" != "${answer#[YESyes]}" ]; then

  docker image prune -a -f
  echo "all non-active images removed"

  docker ps -a
  docker stop $(docker ps -a -q)
  docker rm $(docker ps -a -q)
  echo "stop and remove containers"

  docker rmi $(docker images -a -q)
  echo "remove all other images"

  docker system prune -a --volumes -f
  echo "removed all stopped containers, all networks, all volumes, all images, all build cache!!"

  # exit script after 5 seconds
  sleep 5
  kill -15 $PPID

else
  echo
  echo "You skipped a part of the Docker clean-up!"
  echo "some stopped containers, networks, volumes, images and build cache can still be present!"
  echo
fi
exec 0</dev/tty
