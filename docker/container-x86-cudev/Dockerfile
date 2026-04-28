# DUA environment image.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# March 9, 2026

# Copyright 2026 dotX Automation s.r.l.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM dotxautomation/dua-foundation:x86-cudev

# Change this to match the UID of the owner of this file on the system
ARG USER_UID=1000

ENV DEBIAN_FRONTEND=noninteractive

# IMAGE SETUP START #
ENV ROS_DISTRO=jazzy

# Fix Eigen3 library conflicts by removing conflicting installations
RUN apt remove -y libeigen3-dev || true
RUN rm -rf /usr/local/include/eigen3 /usr/local/share/eigen3 /usr/local/lib/cmake/eigen3 || true

# Install VNC server and desktop environment for web-based RViz viewing
RUN apt-get update && apt-get install -y \
    tigervnc-standalone-server \
    xfce4 \
    xfce4-goodies \
    dbus-x11 \    
    git \
    tmux \
    sshpass \    
    novnc \
    websockify \
    gedit \
    python3-pygments \
    python3-rosinstall-generator \
    python3-vcstool \
    python3-optuna \
    python3-networkx \
    python3-seaborn \
    python3-shapely \
    python3-plotly \
    python3-flask \
    python3-flask-cors \
    python3-socketio \
    iputils-ping \
    libeigen3-dev \    
    pcl-tools \
    && rm -rf /var/lib/apt/lists/*

# Clone noVNC for browser-based VNC access
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify /opt/noVNC/utils/websockify && \
    chown -R root:root /opt/noVNC

# Setup UR5 GZ Sim: https://github.com/UniversalRobots/Universal_Robots_ROS2_GZ_Simulation
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add - 
RUN apt update -y && \
  apt upgrade -y --fix-missing

# Install dependencies
RUN apt install -y \
  ros-${ROS_DISTRO}-ur \  
  ros-${ROS_DISTRO}-ros2-control \
  ros-${ROS_DISTRO}-ros2-controllers \
  ros-${ROS_DISTRO}-gz-ros2-control \
  ros-${ROS_DISTRO}-gz-ros2-control-demos \
  ros-${ROS_DISTRO}-rqt-tf-tree \
  ros-${ROS_DISTRO}-navigation2 \
  ros-${ROS_DISTRO}-nav2-bringup \
  ros-${ROS_DISTRO}-rqt-tf-tree \
  ros-${ROS_DISTRO}-desktop \
  ros-${ROS_DISTRO}-clearpath-gz \
  ros-${ROS_DISTRO}-ouster-ros \
  ros-${ROS_DISTRO}-lms1xx \
  ros-${ROS_DISTRO}-realsense2-camera \
  ros-${ROS_DISTRO}-depthai-ros

# rosdep
RUN sudo rosdep init
RUN rosdep update

# IMAGE SETUP END #

# Create a user with Zsh as shell, hashed password, and add it to the sudoers
# To generate the hashed password, run:
#   mkpasswd -m sha-512 PASSWORD duatemplate
RUN (getent passwd ${USER_UID} || true) && userdel -r $(getent passwd ${USER_UID} | cut -d: -f1) 2>/dev/null || true; \
  useradd -r -m -s /usr/bin/zsh -u ${USER_UID} -G adm,dialout,internal,plugdev,sudo,tty,video -p '$6$duatemplate$YXNq12h0V2FWGbmoeHP6oHJopH4yY9utwuWcjrtXibg0kxIQEjK.IZaij/ufnj1nroxcAMdVS5b9B4Vmv0Yu..' neo
ENV HOME=/home/neo

# Create workspace directory: host workspaces will be mounted here
RUN mkdir ${HOME}/workspace && \
  chown neo:neo ${HOME}/workspace

# Create directory for shell history file
RUN mkdir ${HOME}/zsh_history && \
  chown neo:neo ${HOME}/zsh_history

# Create SSH directory for user
RUN mkdir ${HOME}/.ssh

# Create VNC directory and configuration
RUN mkdir -p ${HOME}/.vnc && \
    chown neo:neo ${HOME}/.vnc

# Create mount point for remote filesystems
RUN mkdir -p /mnt/remote && \
  chown neo:neo /mnt/remote

# Copy user configuration files
COPY --chown=neo:neo ./dua-template/docker/container-x86-cudev/aliases.sh ./.aliases.sh
COPY --chown=neo:neo ./dua-template/docker/container-x86-cudev/bashrc ./.bashrc
COPY --chown=neo:neo ./dua-template/docker/container-x86-cudev/colcon-defaults.yaml /home/neo/colcon-defaults.yaml
COPY --chown=neo:neo ./dua-template/docker/container-x86-cudev/commands.sh ./.commands.sh
COPY --chown=neo:neo ./dua-template/docker/container-x86-cudev/nanorc ./.nanorc
COPY --chown=neo:neo ./dua-template/docker/container-x86-cudev/p10k.zsh ./.p10k.zsh
COPY --chown=neo:neo ./dua-template/docker/container-x86-cudev/ros2.sh ./.ros2.sh
COPY --chown=neo:neo ./dua-template/docker/container-x86-cudev/vimrc ./.vimrc
COPY --chown=neo:neo ./dua-template/docker/container-x86-cudev/zshrc ./.zshrc

RUN mkdir /etc/skel/staging && \
  mv ./.aliases.sh /etc/skel/staging/aliases.sh && \
  mv ./.bashrc /etc/skel/staging/bashrc && \
  mv /home/neo/colcon-defaults.yaml /etc/skel/staging/colcon-defaults.yaml && \
  mv ./.commands.sh /etc/skel/staging/commands.sh && \
  mv ./.nanorc /etc/skel/staging/nanorc && \
  mv ./.p10k.zsh /etc/skel/staging/p10k.zsh && \
  mv ./.ros2.sh /etc/skel/staging/ros2.sh && \
  mv ./.vimrc /etc/skel/staging/vimrc && \
  mv ./.zshrc /etc/skel/staging/zshrc

# Setup web config directory structure
COPY --chown=neo:neo ./dua-template/docker/container-x86-cudev/vnc-xstartup ${HOME}/.vnc/xstartup
RUN chmod +x ${HOME}/.vnc/xstartup
RUN mkdir -p ${HOME}/workspace/config/web
COPY --chown=neo:neo ./dua-template/docker/container-x86-cudev/vnc-xstartup ${HOME}/workspace/config/web/xstartup

# Do the following:
# - Populate /etc/skel with dot-named config files and needed directories, all mount points
# - Handle existing user conflicts and create the internal user
# - Grant passwordless sudo to internal user and suppress hostname resolution warning
# - Create mount point for remote filesystems
RUN mkdir -p /etc/skel/.colcon /etc/skel/.ssh && \
  chmod -R 700 /etc/skel/.ssh && \
  mkdir /etc/skel/workspace /etc/skel/zsh_history && \
  mv /etc/skel/staging/colcon-defaults.yaml /etc/skel/.colcon/defaults.yaml && \
  for f in /etc/skel/staging/*; do mv "$f" "/etc/skel/.$(basename $f)"; done && \
  rmdir /etc/skel/staging; \
  (getent passwd ${USER_UID} || true) && userdel -r $(getent passwd ${USER_UID} | cut -d: -f1) 2>/dev/null || true; \
  useradd -r -m -s /usr/bin/zsh -u ${USER_UID} -G adm,dialout,internal,plugdev,sudo,tty,video neo && \
  printf 'Defaults !fqdn\nneo ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/neo && \
  chmod 0440 /etc/sudoers.d/neo && \
  mkdir -p /mnt/remote && \
  chown -R neo:neo /mnt/remote

# Switch to internal user
USER neo
ENV HOME=/home/neo

# SECOND IMAGE SETUP - LOCAL USER  - START #

# Setup workspace for dependencies from source
ENV MOVEIT_DIR=/home/neo/dep_workspace
RUN mkdir -p ${MOVEIT_DIR}/src
WORKDIR ${MOVEIT_DIR}/src

# Setup Moveit2 from source
# UR5 simulator
RUN git clone -b ros2 https://github.com/UniversalRobots/Universal_Robots_ROS2_GZ_Simulation.git ur_simulation_gz
# moveit2 tutorials
RUN git clone -b main https://github.com/moveit/moveit2_tutorials moveit2_tutorial
RUN vcs import --recursive < ./moveit2_tutorial/moveit2_tutorials.repos
# ros2_reach
RUN git clone -b master https://github.com/ros-industrial/reach_ros2.git
RUN vcs import --recursive < ./reach_ros2/dependencies.repos

USER root
RUN apt remove ros-$ROS_DISTRO-moveit* -y
RUN apt update

RUN rosdep update
RUN rosdep install --ignore-src --from-paths . --rosdistro $ROS_DISTRO -y
RUN chown -R neo:neo ${HOME}/.ros

# Install Python packages in dua-venv
RUN /opt/dua-venv/bin/pip install --upgrade pip
RUN /opt/dua-venv/bin/pip install open3d
RUN /opt/dua-venv/bin/pip install flask_socketio

# Build the workspace with proper environment
USER neo
WORKDIR ${MOVEIT_DIR}
RUN colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml
RUN colcon mixin update default

# Clear any conflicting CMake cache and build
RUN rm -rf build/ install/ log/ || true
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
  colcon build --mixin release --cmake-args -DCMAKE_BUILD_TYPE=Release

# SECOND IMAGE SETUP - LOCAL USER  - END #

# Set the default working directory to the internal user's home
WORKDIR ${HOME}

# Configure Zsh for internal user
ENV ZSH=${HOME}/.oh-my-zsh
ENV ZSH_CUSTOM=${ZSH}/custom
ENV ZSH_PLUGINS=${ZSH_CUSTOM}/plugins
ENV ZSH_THEMES=${ZSH_CUSTOM}/themes
RUN wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | zsh || true; \
  git clone --single-branch --branch 'master' --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_PLUGINS}/zsh-syntax-highlighting; \
  git clone --single-branch --branch 'master' --depth 1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_PLUGINS}/zsh-autosuggestions; \
  git clone --single-branch --depth 1 https://github.com/romkatv/powerlevel10k.git ${ZSH_THEMES}/powerlevel10k

ENV DEBIAN_FRONTEND=dialog

# By default, start a basic shell
CMD ["bash"]
