# 1. FORCE SILENT COMPLETION (The "Zombie Killer")
export ZSH_DISABLE_COMPFIX="true"
# This mocks the security check so it always reports zero insecure folders
compaudit() { return 0; }

# 2. POWERLEVEL10K INSTANT PROMPT
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 3. CONTAINER DETECTION & PATH LOGIC
if [ -n "$CONTAINER_ID" ] || [ -n "$DISTROBOX_ENTER_PATH" ] || [[ "$HOST" == *"cearlab-sandbox"* ]]; then
    export IS_CONTAINER=true
    export ZSH="/opt/oh-my-zsh"
    export ZSH_CUSTOM="/opt/oh-my-zsh/custom"
    export SB_PATH="$HOME/.sandbox"
else
    export IS_CONTAINER=false
    export ZSH="$HOME/.oh-my-zsh"
    export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
fi

# --- HIDDEN CACHE & HISTORY SETUP ---
# Create a dedicated hidden folder for Zsh junk so it doesn't clutter the host ~/
export ZSH_CACHE_DIR="$HOME/.cache/zsh"
[[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"

# Redirect History
export HISTFILE="$ZSH_CACHE_DIR/.zsh_history"

# Redirect Oh-My-Zsh Compdump (the .zcompdump files)
export ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump-${HOST}-${ZSH_VERSION}"

# Basic Prompt for TTY/non-standard terminals
if [[ "$TERM" == "linux" ]]; then
  unalias rm 2>/dev/null
  PROMPT='%B%F{red}%n@%M%f %F{yellow}%~%f %F{white}(%?%) $%f%b '
  return
fi

CASE_SENSITIVE="true"
export LANG=en_US.UTF-8
export EDITOR='nano'

# --- OH-MY-ZSH CONFIGURATION ---
ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':omz:update' mode disabled

# Plugins pre-installed in your Docker image
plugins=(
    git 
    git-extras 
    git-flow 
    colorize 
    command-not-found 
    common-aliases 
    zsh-syntax-highlighting 
    zsh-autosuggestions 
    sudo
)

# 4. SOURCE OH-MY-ZSH
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    # We set this again just to be safe
    ZSH_DISABLE_COMPFIX="true" 
    source "$ZSH/oh-my-zsh.sh"
fi

# --- ROBOTICS LAB LOAD SEQUENCE (CONTAINER ONLY) ---
if [ "$IS_CONTAINER" = true ]; then

    # --- PRIVATE X11 COOKIE SETUP ---
    if [[ "$DISPLAY" == localhost:* ]]; then
        DISP_NUM=$(echo $DISPLAY | awk -F':' '{print $2}' | cut -d'.' -f1)
        
        # 1. Private auth file to keep host clean
        export XAUTHORITY="$HOME/.Xauthority.container"
        cp /dev/null "$XAUTHORITY" 2>/dev/null

        # 2. Get cookie from Host
        MAGIC_COOKIE=$(xauth -f "$HOME/.Xauthority" list | grep -E "unix:${DISP_NUM}[[:blank:]]" | awk '{print $3}' | head -n 1)

        if [ -n "$MAGIC_COOKIE" ]; then
            # 3. Map to EVERY possible way the container might identify itself
            xauth add localhost/unix:${DISP_NUM} MIT-MAGIC-COOKIE-1 $MAGIC_COOKIE
            xauth add 127.0.0.1:${DISP_NUM} MIT-MAGIC-COOKIE-1 $MAGIC_COOKIE
            xauth add $(hostname)/unix:${DISP_NUM} MIT-MAGIC-COOKIE-1 $MAGIC_COOKIE
        fi
        
        # 4. Force IPv4 for maximum stability across Docker network modes
        export DISPLAY="127.0.0.1:${DISP_NUM}.0"
    fi
    
    # 1. Source ROS 2 (Zsh specific)
    [ -f /opt/ros/jazzy/setup.zsh ] && source /opt/ros/jazzy/setup.zsh

    # 2. Source Global Dependency Workspace
    [ -f /opt/dep_workspace/install/setup.zsh ] && source /opt/dep_workspace/install/setup.zsh

    # 3. Source the DUA Virtual Environment
    [ -f /opt/dua-venv/bin/activate ] && source /opt/dua-venv/bin/activate

    # 4. Source Repo-based shell configs from the .sandbox mount
    if [ -d "$SB_PATH" ]; then
        [ -f "$SB_PATH/aliases.sh" ] && source "$SB_PATH/aliases.sh"
        [ -f "$SB_PATH/ros2.sh" ] && source "$SB_PATH/ros2.sh"
        [ -f "$SB_PATH/commands.sh" ] && source "$SB_PATH/commands.sh"
        [ -f "$SB_PATH/dua_submod.sh" ] && source "$SB_PATH/dua_submod.sh"
        [ -f "$SB_PATH/dua_subtree.sh" ] && source "$SB_PATH/dua_subtree.sh"

        # 5. Load the Repo's specific p10k configuration
        [ -f "$SB_PATH/p10k.zsh" ] && source "$SB_PATH/p10k.zsh"

        # Use the Repo's nanorc if available
        [ -f "$SB_PATH/nanorc" ] && alias nano="nano -rcfile $SB_PATH/nanorc"
    fi
    
    export MY_WORKSPACE="$HOME/workspace"
else
    # --- HOST ONLY CONFIG ---
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi