FROM ros:melodic-ros-base
ARG ROSDISTRO


RUN apt-get update && apt-get install -y \
python-pip \
avahi-daemon \
openssh-server \
python-setuptools \
python-dev \
build-essential \
nano \
ros-$ROSDISTRO-roslint \
ros-$ROSDISTRO-rosserial \
ros-$ROSDISTRO-rosserial-arduino \
ros-$ROSDISTRO-imu-filter-madgwick \
ros-$ROSDISTRO-gmapping \
ros-$ROSDISTRO-map-server \
ros-$ROSDISTRO-navigation \
ros-$ROSDISTRO-robot-localization \
ros-$ROSDISTRO-tf2 \
ros-$ROSDISTRO-tf2-ros \
ros-$ROSDISTRO-rplidar-ros

RUN pip install -U platformio
SHELL ["/bin/bash", "-c"] 
RUN source /opt/ros/$ROSDISTRO/setup.bash && echo $_CATKIN_SETUP_DIR
RUN mkdir -p root/linorobot_ws/src
RUN cd /root/linorobot_ws/src && source /opt/ros/$ROSDISTRO/setup.bash && catkin_init_workspace
WORKDIR /root/linorobot_ws/src
RUN pwd
RUN git clone https://github.com/linorobot/linorobot.git
RUN git clone https://github.com/linorobot/imu_calib.git
RUN git clone https://github.com/linorobot/lino_pid.git
RUN git clone https://github.com/linorobot/lino_udev.git
RUN git clone https://github.com/linorobot/lino_msgs.git

RUN cd /root/linorobot_ws/src/linorobot

WORKDIR  /root/linorobot_ws/src/linorobot/teensy/firmware
RUN export PLATFORMIO_CI_SRC=/root/linorobot_ws/src/linorobot/teensy/firmware/src/firmware.ino
ENV PLATFORMIO_CI_SRC=/root/linorobot_ws/src/linorobot/teensy/firmware/src/firmware.ino
RUN platformio ci --project-conf=./platformio.ini --lib="./lib/ros_lib" --lib="./lib/config" --lib="./lib/motor" --lib="./lib/kinematics" --lib="./lib/pid" --lib="./lib/imu" --lib="./lib/encoder"

RUN echo "source /root/linorobot_ws/devel/setup.bash" >> /root/.bashrc
RUN echo "export LINOLIDAR='rplidar'" >> /root/.bashrc
RUN echo "export LINOBASE='2wd'" >> /root/.bashrc
RUN source /opt/ros/$ROSDISTRO/setup.bash && source /root/.bashrc && cd /root/linorobot_ws && catkin_make --pkg lino_msgs && catkin_make
RUN cd /etc/udev && wget https://raw.githubusercontent.com/linorobot/lino_install/master/files/49-teensy.rules


	
