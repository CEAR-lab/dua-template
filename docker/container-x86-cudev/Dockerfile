# DUA environment image.
#
# Federico Oliva <federico.oliva.it@gmail.com>
#
# April 29, 2026.

FROM dotxautomation/dua-foundation:x86-cudev

# ARG for build-time only, Distrobox will override UID at runtime
ARG USER_UID=1000
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=jazzy

# --- IMAGE SETUP START --- #

# Fix Eigen3 conflicts
RUN apt remove -y libeigen3-dev || true && \
    rm -rf /usr/local/include/eigen3 /usr/local/share/eigen3 /usr/local/lib/cmake/eigen3 || true

# Install VNC, Desktop, and Robotics dependencies
RUN apt-get update && apt-get install -y \
    tigervnc-standalone-server xfce4 xfce4-goodies dbus-x11 \    
    git tmux sshpass novnc websockify gedit iputils-ping libeigen3-dev pcl-tools \
    python3-pygments python3-rosinstall-generator python3-vcstool python3-optuna \
    python3-networkx python3-seaborn python3-shapely python3-plotly \
    python3-flask python3-flask-cors python3-socketio \
    && rm -rf /var/lib/apt/lists/*

# Install ROS2 Desktop & Robot Drivers
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    apt update && apt install -y \
    ros-${ROS_DISTRO}-desktop ros-${ROS_DISTRO}-ur ros-${ROS_DISTRO}-ros2-control \
    ros-${ROS_DISTRO}-ros2-controllers ros-${ROS_DISTRO}-gz-ros2-control \
    ros-${ROS_DISTRO}-navigation2 ros-${ROS_DISTRO}-nav2-bringup \
    ros-${ROS_DISTRO}-clearpath-gz ros-${ROS_DISTRO}-ouster-ros \
    ros-${ROS_DISTRO}-realsense2-camera ros-${ROS_DISTRO}-depthai-ros \
    && rosdep init || true && rosdep update

# --- DISTROBOX COMPATIBILITY SETUP --- #

# Grant global passwordless sudo (needed for Distrobox user mapping)
RUN echo "ALL ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/distrobox_sudoers

# --- SECOND IMAGE SETUP (Pre-build MoveIt2 Workspace) --- #

# We build this in /opt so it is accessible to all users
ENV MOVEIT_DIR=/opt/dep_workspace
RUN mkdir -p ${MOVEIT_DIR}/src
WORKDIR ${MOVEIT_DIR}/src

RUN git clone -b ros2 https://github.com/UniversalRobots/Universal_Robots_ROS2_GZ_Simulation.git && \
    git clone -b main https://github.com/moveit/moveit2_tutorials && \
    vcs import < ./moveit2_tutorials/moveit2_tutorials.repos && \
    apt update && rosdep install --ignore-src --from-paths . --rosdistro $ROS_DISTRO -y

WORKDIR ${MOVEIT_DIR}
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    colcon build \
      --cmake-args \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# --- GLOBAL SHELL CONFIG (Oh-My-Zsh in /opt) --- #

# We install OMZ to /opt/oh-my-zsh so it's shared and doesn't break if a user deletes their home
ENV ZSH=/opt/oh-my-zsh
RUN wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | zsh || true && \
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH}/custom/plugins/zsh-syntax-highlighting && \
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH}/custom/plugins/zsh-autosuggestions && \
    git clone --depth 1 https://github.com/romkatv/powerlevel10k.git ${ZSH}/custom/themes/powerlevel10k && \
    chmod -R 777 /opt/oh-my-zsh

# Python environment setup
RUN /opt/dua-venv/bin/pip install --upgrade pip open3d flask_socketio

# Finalize
WORKDIR /
ENV DEBIAN_FRONTEND=dialog
CMD ["/usr/bin/zsh"]