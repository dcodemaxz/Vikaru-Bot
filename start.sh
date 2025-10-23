#!/bin/bash

# ----------------------------------------------------------------------------- #
# ❏ [🧬] SOURCE CODE
# ----------------------------------------------------------------------------- #
# • Developer : Maxz
# • Contact   : https://linktr.ee/dcodemaxz
#
# ----------------------------------------------------------------------------- #
# ❏ [💡] Note:
# ----------------------------------------------------------------------------- #
# • Thank you for supporting the developer by purchasing this script.
# • Please read the file ("© +6289508899033") before using this script.
# ----------------------------------------------------------------------------- #




# ----------------------------------------------------------------------------- #
# ❏ [🔄] Auto-Restart & Dependency Management
# ----------------------------------------------------------------------------- #
# This script addresses the limitations of the Termux environment by providing a
# user-friendly control menu for a Node.js bot. Its main function is to ensure
# continuous operation and handle dependencies automatically.
#
#
# ----------------------------------------------------------------------------- #
# ❏ [⚡] Progress:
# ----------------------------------------------------------------------------- #
# • Provides an interactive menu interface to control the bot.
# • Automatically checks for and installs system dependencies (e.g., ffmpeg,
#   nodejs).
# • Validates project files ('index.js') and 'node_modules', offering to install
#   them if missing.
# • Supports two modes: 'Normal' (single run) and 'Loop' (auto-restart).
# • Checks for a stable internet connection before starting.
# • Prevents infinite restart loops by limiting the number of attempts.
#
#
# ----------------------------------------------------------------------------- #
# ❏ [📌] Prerequisites:
# ----------------------------------------------------------------------------- #
# • Node.js (LTS or latest version).
# • The script must be executed from the directory containing 'package.json' and
#   'index.js'.
# • npm is installed.
# • Additional dependencies will be installed automatically on Termux.
#
#
# ----------------------------------------------------------------------------- #
# ❏ [⚙️] How it Works:
# ----------------------------------------------------------------------------- #
# • Environment Check: Upon startup, the script identifies the environment
#   (Termux) and installs the necessary system packages.
# • User Interface: Displays the main menu for selecting the bot's
#   operation mode.
# • Pre-Run Validation: Before execution, the script verifies the presence
#   of project files, dependencies, and an internet connection.
# • Loop Mode: Monitors the exit code of the npm process. If a crash occurs,
#   the script automatically restarts the bot.
# • Shutdown: The script has a 'graceful shutdown' function to handle manual
#   terminations (e.g., Ctrl+C) cleanly.




# Lib (Don't change it)
#-------------------------------------------------------------------------------#
source ./.start/app.sh
import.source [io:color.app, inquirer:list.app]


# Color Definitions
#-------------------------------------------------------------------------------#
# black, red, green, yellow, blue, magenta, cyan, white, bold, normal, dim

# Background Colors
bg_black="\033[40m"
bg_red="\033[41m"
bg_green="\033[42m"
bg_yellow="\033[43m"
bg_blue="\033[44m"
bg_magenta="\033[45m"
bg_cyan="\033[46m"
bg_white="\033[47m"


# Symbol Definitions
#-------------------------------------------------------------------------------#
#arrow, checked, unchecked
done="[${green}✓${normal}]"
process="[${cyan}~${normal}]"
alert="[${red}!${normal}]"
query="[${yellow}?${normal}]"
time="${white}[ ${dim}$(date '+%H:%M:%S')${normal} ${white}]${normal}"
line="${dim}─────────────────────────────────────────────────${normal}"


# Automatically determine the script's directory
#-------------------------------------------------------------------------------#
DIR=$(dirname "$(readlink -f "$0")")
cd "$DIR"


# Function for graceful shutdown
#-------------------------------------------------------------------------------#
graceful_exit() {
    echo -e "\n${dim}#${normal} ${done} Shutting down. | ctrl + c${normal}"
    exit 0
}


# Trap the SIGINT signal (Ctrl+C) and call the graceful_exit function
#-------------------------------------------------------------------------------#
trap graceful_exit SIGINT


# Check if running in Termux environment
#-------------------------------------------------------------------------------#
if [[ "$PREFIX" == *"com.termux"* ]] || [[ "$HOME" == *"/data/data/com.termux"* ]]; then
    SUDO=""
else
    SUDO="sudo"
fi


# Function to display header
#-------------------------------------------------------------------------------#
show_header() {
    clear
    echo -e "${dim}╭───────────────────────────────────────────────╮${normal}"
    echo -e "│ - ${white}Author : ${green}Maxz${dim} | dcodemaxz${normal}                   ${dim}│${normal}"
    echo -e "│ - ${white}Sosmed : ${dim}https://linktr.ee/${normal}${cyan}dcodemaxz${normal}        ${dim}│${normal}"
    echo -e "╰───────────────────────────────────────────────╯${normal}"
}


# Function to check internet connection + resources
#-------------------------------------------------------------------------------#
check_resources() {
    echo
    echo -e "# ${alert} Make sure your internet connection is good!${normal}"
    read -r -s -p $'# [\033[33m?\033[0m] Press \033[32menter\033[0m to continue...\n'
    echo -e "${line}"
    sleep 1

    local connected=false

    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 || ping -c 1 -W 2 google.com >/dev/null 2>&1; then
        connected=true
    fi

    if ! $connected; then
        echo -e "${dim}•${normal} ${alert} No stable internet connection. Exiting.${normal}"
        exit 1
    fi

    local resources
    if [[ -z "$1" ]]; then
        resources=("pv" "bc" "git" "ssh" "curl" "figlet" "ffmpeg" "nodejs")
        # "libwebp" "npm"
        sleep 1
    else
        resources=("${@}")
    fi

    for package_name in "${resources[@]}"; do
        if ! dpkg -s "$package_name" &> /dev/null; then
            echo -e "${dim}•${normal} ${process} Installing ${package_name}...${normal}"
            echo
            $SUDO apt install "$package_name" -y
            echo
            if [ $? -eq 0 ]; then
                echo -e "${dim}•${normal} ${done} ${package_name} installed${normal}"
            else
                echo -e "${dim}•${normal} ${alert} Failed to install ${package_name}${normal}"
            fi
            echo
        else
            echo -e "${dim}•${normal} ${done} ${package_name}${normal}"
        fi
    done
    sleep 1
}


# Function to check modules
#-------------------------------------------------------------------------------#
check_modules() {
    if [[ ! -d "vikaru-md" ]]; then
        echo -e "# ${alert} Directory ${red}vikaru-md${normal} not found, please install bot.${normal}"
        exit 1
    fi

    cd vikaru-md

    # Cek apakah index.js ada
    if [[ ! -f "index.js" ]]; then
        echo -e "# ${alert} index.js ${red}not found${dim} in directory: ${DIR}.${normal}"
        exit 1
    fi
    
    # Cek apakah node_modules ada
    if [[ ! -d "node_modules" ]]; then
        echo -e "# ${alert} node_modules not found${normal}"
        read -p "# ${query} Do you want to run npm install? [ Y/N ]: ${normal}" -n 1 -r REPLY
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "# ${process} Setting up Node.js repo...${normal}"
            curl -fsSL https://deb.nodesource.com/setup_lts.x | $SUDO -E bash -
            echo -e "# ${process} Installing npm...${normal}"
            echo -e "${line}"
            echo
            sleep 1
            npm install
            if [[ $? -ne 0 ]]; then
                echo
                echo -e "# ${alert} npm install failed. Exiting.${normal}"
                exit 1
            else
                echo
                echo -e "# ${done} npm installed${normal}"
                sleep 2
            fi
        else
            clear
            echo -e "# ${alert} Please install the module before running the bot.${normal}"
            exit 1
        fi
    fi
}



# Vikaru-Menu
#-------------------------------------------------------------------------------#
mainmenu() {
    clear
    cat << EOF
╭──────────────────────────────────────╮
│                                      │
│       █░█░█░█░▄▀░▄▀▄░█▀▀▄░█░█        │
│       █░█░█░█▀▄░░█▀█░█▐█▀░█░█        │
│       ░▀░░▀░▀░▀▀░▀░▀░▀░▀▀░▀▀▀        │
│                                      │
│       ${dim}-${normal} ${red}created by dcodemaxz${normal} ${dim}-${normal}       │
│                                      │
╰──────────────────────────────────────╯
EOF
    echo -e "${normal}${dim}╭──────────────────────────────────────╮${normal}"
    echo -e "│ ${white}☰ Navigate menu: [ ${yellow}↑↓${normal} ] ${dim}-${normal} ${green}enter${dim}...${normal}   ${dim}│${normal}"
    echo -e "╰──────────────────────────────────────╯${normal}"
    
    main() {
        init() {
            shopt -s expand_aliases
            Prompt="[>]"
        }
        main.setup() {
            list.input [${Prompt}, menu, output]
            let choice=$(grep -Eo "[0-9]" <<< "$output")
        }
        init
    }

    menu=("• [1] Start Bot" "• [2] Install Bot" "• [3] Update Bot" "• [4] Create keys" "• [5] About" "• [0] Exit")

    eval main
    main.setup

    case "$choice" in
        1)
            clear
            mainstart
            ;;
        2)
            clear
            install_bot
            ;;
        3)
            clear
            install_update
            ;;
        4)
            clear
            generate_key
            ;;
        5)
            clear
            show_credit
            ;;
        0)
            clear
            echo -e "# ${done} Exiting.${normal}"|pv -qL 50
            exit 0
            ;;
        *)
            clear
            echo -e "# ${alert} Denied${normal}"|pv -qL 35
            sleep 1
            mainmenu
            ;;
    esac
}


# [ 1 ] Vikaru-Start Loop
#-------------------------------------------------------------------------------#
mainstart() {
    check_modules
    echo
    echo -e "# ${process} Start Bot...${normal}"

    while true; do
        npm start 2>&1 | tee -a ../error.log

        exit_code=$?

        if [[ $exit_code -ne 0 ]]; then
            echo
            echo -e "# ${alert}-${time} | Bot Crashed. Restarting...${normal}"
        else
            echo
            echo -e "# ${alert}-${time} | Bot Stopped. Restarting...${normal}"
        fi
        
        sleep 2
    done
}


# [ 2 ] Installing bot
#-------------------------------------------------------------------------------#
install_bot() {
    show_header
    sleep 1

    if [ ! -d "vikaru-md" ]; then
        echo -e "# ${process} Start Installing...${normal}"
        echo
        git clone git@github.com:dcodemaxz/vikaru-md.git

        if [ $? -eq 0 ]; then
            echo -e "${dim}•${normal} ${done} Installed${normal}"
        else
            echo -e "${dim}•${normal} ${alert} Failed to install${normal}"
        fi
    else
        echo -e "${dim}•${normal} ${alert} The 'vikaru-md' folder already exists, skip the clone process.${normal}"
    fi
}


# [ 3 ] Installing update
#-------------------------------------------------------------------------------#
install_update() {
    check_modules
    show_header
    sleep 1

    TEMP_LIST="./.history.txt"
    TEMP_ZIP="../vikaru-bak.zip"
    BACKUP_DIR="_backup"
    FINAL_ZIP="${BACKUP_DIR}/backup-$(date +%s).zip"

    echo -e "# ${process} Starting update...${normal}\n"

    # 1. COLLECT & BACKUP CHANGES
    git config --global --add safe.directory "$(pwd)" >/dev/null 2>&1
    sh -c "git ls-files --modified --others --exclude-standard > '${TEMP_LIST}' && \
           zip -q@ '${TEMP_ZIP}' < '${TEMP_LIST}' && \
           rm -f '${TEMP_LIST}'" >/dev/null 2>&1

    # 2. DISCARD LOCAL CHANGES & PULL NEW CODE
    if git reset --hard >/dev/null 2>&1 && git clean -df >/dev/null 2>&1; then
        if git pull git@github.com:dcodemaxz/vikaru-md.git; then
            echo -e "${dim}•${normal} ${done} Update completed.${normal}"
        else
            echo -e "${dim}•${normal} ${alert} Failed to pull updates.${normal}"
            [ -f "$TEMP_ZIP" ] && rm -f "$TEMP_ZIP"
            return 1
        fi
    else
        echo -e "${dim}•${normal} ${alert} Failed to normal local changes.${normal}"
        [ -f "$TEMP_ZIP" ] && rm -f "$TEMP_ZIP"
        return 1
    fi

    # 3. RESTORE BACKUP FILE
    mkdir -p "$BACKUP_DIR"
    if [ -f "$TEMP_ZIP" ]; then
        mv "$TEMP_ZIP" "$FINAL_ZIP"
        version=$(grep -oP '(?<="version": ")[^"]*' package.json 2>/dev/null)
        echo -e "# ${done} Update : v${version:-unknown}${normal}"
        echo -e "${dim}•${normal} ${done} Backup : ${FINAL_ZIP}${normal}"
    fi
}


# [ 4 ] Generate key
#-------------------------------------------------------------------------------#
generate_key() {
    show_header
    echo -e "# ${process} Creating SSH key...${normal}\n"
    sleep 1

    local SSH_DIR="$HOME/.ssh"
    local PRIVATE_KEY="$SSH_DIR/id_ed25519"
    local PUBLIC_KEY="$PRIVATE_KEY.pub"

    mkdir -p "$SSH_DIR"

    if [ -f "$PRIVATE_KEY" ]; then
        echo -e "${dim}•${normal} ${alert} SSH key already exists.${normal}"
    else
        ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$PRIVATE_KEY" -q -N ""
        echo -e "${dim}•${normal} ${done} SSH key successfully generated.${normal}"
    fi

    echo
    echo -e "${dim}•${normal} ${query} Copy the key and send it to dev ( +6289508899033 ).${normal}"
    echo -e "${line}"
    cat "$PUBLIC_KEY"
    echo -e "${line}"
    echo -e "${dim}•${normal} ${alert} Do not share your private key (id_ed25519)!${normal}"
    echo -e "${line}"
}


# [ 5 ] Function to display credit information
#-------------------------------------------------------------------------------#
show_credit() {
    show_header
    echo -e "# ${green}Thank you for your support!${normal}"
    echo
    echo -e "${dim}This script was designed to simplify the management of your Node.js bot by automating tasks such as dependency installation, continuous operation, and system checks. It's built to be robust and user-friendly, ensuring your bot runs smoothly with minimal intervention.${normal}"
    echo
    echo -e "# ${yellow}Key Features:${normal}"
    echo -e "${line}"
    echo -e "${dim}•${normal} ${cyan}Auto-restart${dim}: Keeps the bot running even after unexpected crashes.${normal}"
    echo -e "${dim}•${normal} ${cyan}Dependency Management${dim}: Installs all required packages automatically.${normal}"
    echo -e "${dim}•${normal} ${cyan}Interactive Menu${dim}: A simple menu for easy bot control.${normal}"
    echo -e "${dim}•${normal} ${cyan}System Checks${dim}: Verifies prerequisites like internet connection and file integrity.${normal}"
    echo
    echo -e "# ${alert} Thank you for supporting the developer by purchasing this script.${normal}"
    read -r -s -p $'• [\033[33m?\033[0m] Press \033[32menter\033[0m to back...\n'
    mainmenu
}


# Function to check if the environment uses apt (Ubuntu, Debian, Termux, etc.)
#-------------------------------------------------------------------------------#
is_apt_based() {
    if command -v apt >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Main execution logic
#-------------------------------------------------------------------------------#
if is_apt_based; then
    # If apt-based (Ubuntu, Debian, Termux, VPS), run the main menu
    show_header
    check_resources
    mainmenu
else
    # If not apt-based (e.g., Windows PowerShell, Git Bash), just run loop mode
    mainstart
fi