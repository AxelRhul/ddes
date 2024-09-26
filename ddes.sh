#!/bin/bash

# Check if a command exists

check_command() {
    command -v $1 >/dev/null 2>&1
}

# Annimation 

loading_animation() {
    local message=${1:-"Chargement en cours"}
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    local msg_length=${#message}
    tput civis
    echo -n "$message"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "\r"
    for ((i=0; i<msg_length+8; i++)); do
        printf " "
    done
    printf "\r"
    tput cnorm
}

# Check if sudo is installed

if ! check_command sudo ; then
  echo "sudo is not installed. Installing it with apt..."
  apt-get update >/dev/null 2>&1 & loading_animation "Updating package list"
  apt-get install sudo -y >/dev/null 2>&1 & loading_animation "Installing sudo"
  echo "sudo installed successfully."
  sleep 1
fi

# Global variables

installed_php_versions=()


# Display status 


display_tool_status() {
    if check_command $1; then
        echo -e "\e[32m$1 is already installed.\e[0m"
    else
        echo -e "\e[31m$1 is not installed.\e[0m"
    fi
}


display_php_status() {
    if [ ! -d "/etc/php/" ]; then
        echo -e "\e[31mPHP is not installed.\e[0m"
        return
    fi

    installed_php_versions=($(ls /etc/php/))

    if [ ${#installed_php_versions[@]} -eq 0 ]; then
        echo -e "\e[31mNo PHP versions are installed.\e[0m"
        return
    fi

    for version in "${installed_php_versions[@]}"; do
        echo -e "\e[32mPHP $version is installed.\e[0m"
    done
}

display_nvm_status(){
    if [ -n "$NVM_DIR" ] && [[ -s $NVM_DIR/nvm.sh ]]; then
        echo -e "\e[32mNVM is already installed.\e[0m"
    else
        echo -e "\e[31mNVM is not installed.\e[0m"
    fi
}

display_tools(){
    display_php_status
    display_tool_status "composer"
    display_tool_status "symfony"
    display_nvm_status
}

# Install 

## Dependencies

install_dependency() {
    check_command $1 || sudo apt install -y $1 >/dev/null 2>&1 & loading_animation "Installing $1"
}

## PHP

pre_install_php() {
    sudo apt-get install software-properties-common -y >/dev/null 2>&1 & loading_animation "Installing software-properties-common"
    sudo add-apt-repository ppa:ondrej/php -y >/dev/null 2>&1 & loading_animation "Adding PHP repository"
    sudo apt-get update -y >/dev/null 2>&1 & loading_animation "Updating package list"
}

install_php() {
    php_version=$1
    
    version_compare=$(echo "$php_version" | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }')
    version_8_0_0=$(echo "8.0.0" | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }')

    if [ "$version_compare" -ge "$version_8_0_0" ]; then
        sudo apt-get install -y php$php_version libapache2-mod-php$php_version libapache2-mod-fcgid php$php_version-cli php$php_version-common php$php_version-fpm php$php_version-mysql php$php_version-zip php$php_version-gd php$php_version-mbstring php$php_version-curl php$php_version-xml openssl php$php_version-intl >/dev/null 2>&1 & loading_animation "Installing PHP $php_version" 
    else
        sudo apt-get install -y php$php_version libapache2-mod-php$php_version libapache2-mod-fcgid php$php_version-cli php$php_version-common php$php_version-fpm php$php_version-mysql php$php_version-zip php$php_version-gd php$php_version-mbstring php$php_version-curl php$php_version-xml openssl php$php_version-json php$php_version-intl >/dev/null 2>&1 & loading_animation "Installing PHP $php_version" 
    fi

    installed_php_versions+=("$php_version")
    echo -e "\e[32mPHP $php_version installed successfully.\e[0m"
}

full_install_php() {
    pre_install_php
    read -p "Enter PHP version(s) to install (comma-separated, e.g., 7.4,8.0): " php_versions
    IFS=',' read -ra php_versions_array <<< "$php_versions" 

    for version in "${php_versions_array[@]}"; do
        install_php "$version"
    done
}

## Composer

install_composer() {
    install_dependency "curl"

    if [ ! -d "/etc/php/" ]; then
        echo "PHP is not installed. Installing PHP..."
        full_install_php
    fi
    
    if ! check_command composer; then
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php composer-setup.php --install-dir=/usr/local/bin --filename=composer >/dev/null 2>&1 & loading_animation "Installing Composer"
        php -r "unlink('composer-setup.php');"
        echo -e "\e[32mComposer installed successfully."
    else
        echo "Composer is already installed."
    fi
}

## Symfony

install_symfony() {
    install_dependency "curl" && install_dependency "git"

    if ! check_command composer; then
        install_composer
    fi

    curl -sS https://get.symfony.com/cli/installer | bash >/dev/null 2>&1 & loading_animation "Installing Symfony"
    sudo mv $HOME/.symfony5/bin/symfony /usr/local/bin/symfony

    echo -e "\e[32mSymfony installed successfully.\e[0m"
}

## NVM

install_nvm() {
    install_dependency "curl"

    check_command nvm || {
        curl -sS https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash >/dev/null 2>&1 & loading_animation "Installing NVM"
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    }
    source ~/.bashrc
}

## All

install_all() {
    full_install_php
    install_composer
    install_symfony
    install_nvm
    sleep 2
}

# Menu

display_menu() {
    local options=("Install NVM" "Install Symfony" "Install Composer" "Install PHP" "Install All" "Quit")
    local selected=0

    draw_menu() {
        tput cup 0 0 
        display_tools
        echo "Use the arrow keys to navigate and Enter to select:"
        for i in "${!options[@]}"; do
            if [ $i -eq $selected ]; then
                echo -e "\e[1;34m> ${options[$i]}\e[0m"
            else
                echo "  ${options[$i]}"
            fi
        done
    }

    clear
    tput civis
    draw_menu

    while true; do
        read -rsn1 input
        case $input in
            $'\x1b')
                read -rsn2 -t 0.1 input
                if [[ $input == "[A" ]]; then
                    ((selected--))
                    if [ $selected -lt 0 ]; then
                        selected=$((${#options[@]} - 1))
                    fi
                elif [[ $input == "[B" ]]; then
                    ((selected++))
                    if [ $selected -ge ${#options[@]} ]; then
                        selected=0
                    fi
                fi
                draw_menu
                ;;
            "")
                tput cnorm
                case ${options[$selected]} in
                    "Install NVM")
                        install_nvm
                        echo -e "\e[32mNVM installation complete.\e[0m"
                        ;;
                    "Install Symfony")
                        install_symfony
                        echo -e "\e[32mSymfony installation complete.\e[0m"
                        ;;
                    "Install Composer")
                        install_composer
                        echo -e "\e[32mComposer installation complete.\e[0m"
                        ;;
                    "Install PHP")
                        full_install_php
                        echo -e "\e[32mPHP installation complete.\e[0m"
                        ;;
                    "Install All")
                        install_all
                        echo -e "\e[32mAll installation complete.\e[0m"
                        ;;
                    "Quit")
                        echo "Goodbye!"
                        tput cnorm  # Restaurer le curseur
                        exit 0
                        ;;
                esac
                clear
                tput civis
                draw_menu
                ;;
        esac
    done
    tput cnorm
}

# Appel de la fonction display_menu
display_menu
