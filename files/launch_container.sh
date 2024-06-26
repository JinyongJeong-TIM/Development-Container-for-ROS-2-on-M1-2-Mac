#!/bin/sh
SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
cd $SCRIPT_DIR

NAME_IMAGE="development-container-for-ros-2-on-m1-2-mac_for_${USER}"

if [ ! "$(docker image ls -q ${NAME_IMAGE})" ]; then
	if [ ! $# -ne 1 ]; then
		if [ "build" = $1 ]; then
			echo "Image ${NAME_IMAGE} does not exist."
			echo 'Now building image without proxy...'
			docker build --file=./Dockerfile -t $NAME_IMAGE . --build-arg UID=$(id -u) --build-arg GID=$(id -u) --build-arg UNAME=$USER --build-arg SETLOCALE='JP'
			exit 0
		else
			echo "Docker image is not found. Please setup first!"
			exit 0
		fi
    elif [ ! $# -ne 2 ]; then
		if [ "build" = $1 ]; then
			if [ "US" = $2 ]; then
				echo "Image ${NAME_IMAGE} does not exist."
				echo 'Now building image without proxy...'
				docker build --file=./Dockerfile -t $NAME_IMAGE . --build-arg UID=$(id -u) --build-arg GID=$(id -u) --build-arg UNAME=$USER --build-arg LOCALE='US'
				exit 0
			else
				echo "Image ${NAME_IMAGE} does not exist."
				echo 'Now building image without proxy...'
				docker build --file=./Dockerfile -t $NAME_IMAGE . --build-arg UID=$(id -u) --build-arg GID=$(id -u) --build-arg UNAME=$USER --build-arg LOCALE='JP'
				exit 0
			fi
		else
			echo "Docker image is not found. Please setup first!"
			exit 0
		fi
    else
		echo "Docker image is not found. Please setup first!"
		exit 0
  	fi
else
	if [ ! $# -ne 1 ]; then
		if [ "build" = $1 ]; then
			echo "Docker image is found. Please select mode!"
			exit 0
		fi
    elif [ ! $# -ne 2 ]; then
		if [ "build" = $1 ]; then
			echo "Docker image is found. Please select mode!"
			exit 0
		fi
  	fi
fi

# Commit
if [ ! $# -ne 1 ]; then
	if [ "commit" = $1 ]; then
		echo 'Commit changes to the image'
		docker commit development-container-for-ros-2-on-m1-2-mac_for_${USER}_container development-container-for-ros-2-on-m1-2-mac_for_${USER}:latest
		exit 0
	fi
fi

# Stop
if [ ! $# -ne 1 ]; then
	if [ "stop" = $1 ]; then
		echo 'Stop container..'
		CONTAINER_ID=$(docker ps -a -f name=development-container-for-ros-2-on-m1-2-mac_for_${USER}_container --format "{{.ID}}")
		docker stop $CONTAINER_ID
		exit 0
	fi
fi
# Clear
if [ ! $# -ne 1 ]; then
	if [ "clear" = $1 ]; then
		echo 'Now deleting docker container...'
		CONTAINER_ID=$(docker ps -a -f name=development-container-for-ros-2-on-m1-2-mac_for_${USER}_container --format "{{.ID}}")
		docker stop $CONTAINER_ID
		docker rm $CONTAINER_ID -f
		exit 0
	fi
fi

# Delete
if [ ! $# -ne 1 ]; then
	if [ "delete" = $1 ]; then
		echo 'Now deleting docker container...'
		CONTAINER_ID=$(docker ps -a -f name=development-container-for-ros-2-on-m1-2-mac_for_${USER}_container --format "{{.ID}}")
		docker stop $CONTAINER_ID
		docker rm $CONTAINER_ID -f
		docker image rm development-container-for-ros-2-on-m1-2-mac_for_${USER}
		exit 0
	fi
fi

XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
if [ ! -z "$xauth_list" ];  then
  echo $xauth_list | xauth -f $XAUTH nmerge -
fi
chmod a+r $XAUTH

DOCKER_OPT=""
DOCKER_NAME="development-container-for-ros-2-on-m1-2-mac_for_${USER}_container"
DOCKER_WORK_DIR="/home/${USER}"
MAC_WORK_DIR="/Users/${USER}"
DISPLAY=$(hostname):0

## For XWindow
DOCKER_OPT="${DOCKER_OPT} \
        --env=QT_X11_NO_MITSHM=1 \
        --volume=/tmp/.X11-unix:/tmp/.X11-unix:rw \
        --volume=/Users/${USER}:/home/${USER}/host_home:rw \
        --env=XAUTHORITY=${XAUTH} \
        --volume=${XAUTH}:${XAUTH} \
        --env=DISPLAY=${DISPLAY} \
	--shm-size=4gb \
	--env=TERM=xterm-256color \
        -w ${DOCKER_WORK_DIR} \
        -u ${USER} \
        --hostname Docker-`hostname` \
        --add-host Docker-`hostname`:127.0.1.1 \
	-p 3389:3389 \
	-e PASSWD=${USER}"
		
		
## Allow X11 Connection
xhost +local:`hostname`
CONTAINER_ID=$(docker ps -a -f name=development-container-for-ros-2-on-m1-2-mac_for_${USER}_container --format "{{.ID}}")
if [ ! "$CONTAINER_ID" ]; then
	if [ ! $# -ne 1 ]; then
		if [ "xrdp" = $1 ]; then
		    echo "Remote Desktop Mode"
			docker run ${DOCKER_OPT} \
				--name=${DOCKER_NAME} \
				--entrypoint docker-entrypoint.sh \
			        --restart always \
				development-container-for-ros-2-on-m1-2-mac_for_${USER}:latest
		else
			docker run ${DOCKER_OPT} \
				--name=${DOCKER_NAME} \
				--volume=$MAC_WORK_DIR/.Xauthority:$DOCKER_WORK_DIR/.Xauthority:rw \
				-it \
				--entrypoint /bin/bash \
				--restart always \
				development-container-for-ros-2-on-m1-2-mac_for_${USER}:latest
		fi
	else
		docker run ${DOCKER_OPT} \
			--name=${DOCKER_NAME} \
			--volume=$MAC_WORK_DIR/.Xauthority:$DOCKER_WORK_DIR/.Xauthority:rw \
			-it \
			--entrypoint /bin/bash \
			--restart always \
			development-container-for-ros-2-on-m1-2-mac_for_${USER}:latest
	fi
else
	if [ ! $# -ne 1 ]; then
		if [ "xrdp" = $1 ]; then
		    echo "Remote Desktop Mode"
			docker run ${DOCKER_OPT} \
				--name=${DOCKER_NAME} \
				--volume=$MAC_WORK_DIR/.Xauthority:$DOCKER_WORK_DIR/.Xauthority:rw \
				--entrypoint docker-entrypoint.sh \
				--restart always \
				development-container-for-ros-2-on-m1-2-mac_for_${USER}:latest
		else
			docker start $CONTAINER_ID
			docker exec -it $CONTAINER_ID /bin/bash
		fi
	else
		docker start $CONTAINER_ID
		docker exec -it $CONTAINER_ID /bin/bash
	fi
fi

xhost -local:`hostname`

