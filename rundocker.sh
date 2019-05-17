#!/usr/bin/env bash

xterm -hold -e socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &

docker run --rm -it -v `pwd`:/home/microc -w=/home/microc -e DISPLAY=$(ipconfig getifaddr en0):0 -v /tmp/.X11-unix:/tmp/.X11-unix kuroiwakun/2019spring-plt
