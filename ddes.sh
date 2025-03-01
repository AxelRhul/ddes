#!/bin/bash

#========================================================CRTL+C START========================================================#

cleanup() {
    tput cnorm
    exit 0
}


trap cleanup SIGINT

#========================================================CRTL+C END========================================================#





#========================================================ANIMATION START======================================================#

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

#========================================================ANIMATION END========================================================#





#========================================================MISC START========================================================#

installed_php_versions=()

check_command() {
    command -v $1 >/dev/null 2>&1
}

install_dependency() {
    check_command $1 || sudo apt install -y $1 >/dev/null 2>&1 & loading_animation "Installing $1"
}

if ! check_command sudo ; then
  echo "sudo is not installed. Installing it with apt..."
  apt-get update >/dev/null 2>&1 & loading_animation "Updating package list"
  apt-get install sudo -y >/dev/null 2>&1 & loading_animation "Installing sudo"
  echo "sudo installed successfully."
  sleep 1
fi

#========================================================MISC END========================================================#





#========================================================PHP START========================================================#
check_php_is_installed(){
    if [ -d "/etc/php/" ]; then
        return 0
    fi
    return 1
}

display_php_status() {
    if ! check_php_is_installed ; then
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

remove_php_version() {
    php_version=$1
    version_compare=$(echo "$php_version" | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }')
    version_8_0_0=$(echo "8.0.0" | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }')

    if [ "$version_compare" -ge "$version_8_0_0" ]; then
        sudo apt-get remove --purge -y php$php_version libapache2-mod-php$php_version libapache2-mod-fcgid php$php_version-cli php$php_version-common php$php_version-fpm php$php_version-mysql php$php_version-zip php$php_version-gd php$php_version-mbstring php$php_version-curl php$php_version-xml openssl php$php_version-intl >/dev/null 2>&1 & loading_animation "Removing PHP $php_version"
    else
        sudo apt-get remove --purge -y php$php_version libapache2-mod-php$php_version libapache2-mod-fcgid php$php_version-cli php$php_version-common php$php_version-fpm php$php_version-mysql php$php_version-zip php$php_version-gd php$php_version-mbstring php$php_version-curl php$php_version-xml openssl php$php_version-json php$php_version-intl >/dev/null 2>&1 & loading_animation "Removing PHP $php_version"
    fi
}

remove_php() {

    if check_command symfony; then
        echo "Removing Symfony before Composer..."
        remove_symfony
    fi


    if check_command composer; then
        echo "Removing Composer before PHP..."
        remove_composer
    fi

    if check_php_is_installed; then
        for version in "${installed_php_versions[@]}"; do
           remove_php_version "$version"
        done
    fi

    sudo add-apt-repository --remove ppa:ondrej/php -y >/dev/null 2>&1 & loading_animation "Removing PHP repository"

    sudo apt autoremove --purge -y >/dev/null 2>&1 & loading_animation "Removing PHP dependencies"

    echo -e "\e[32mPHP removed successfully.\e[0m"
}
#========================================================PHP END========================================================#





#========================================================COMPOSER START========================================================#

display_composer_status() {
    if check_command composer; then
        version=$(composer -V 2>&1 | grep "Composer version")
        echo -e "\e[32mComposer (\e[33m$version\e[32m) is already installed.\e[0m"
    else
        echo -e "\e[31mComposer is not installed.\e[0m"
    fi
}

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

remove_composer() {
    if check_command symfony; then
        echo "Removing Symfony before Composer..."
        remove_symfony
    fi

    if check_command composer; then
        sudo rm /usr/local/bin/composer & loading_animation "Removing Composer"
    fi

    echo -e "\e[32mComposer removed successfully.\e[0m"
}
#========================================================COMPOSER END========================================================#





#========================================================SYMFONY START========================================================#

display_symfony_status() {
    if check_command symfony; then
        version=$(symfony -V | sed 's/\x1b\[[0-9;]*m//g')
        echo -e "\e[32mSymfony (\e[33m$version\e[32m) is already installed.\e[0m"
    else
        echo -e "\e[31mSymfony is not installed.\e[0m"
    fi
}

install_symfony() {
    install_dependency "curl" && install_dependency "git"

    if ! check_command composer; then
        install_composer
    fi

    curl -sS https://get.symfony.com/cli/installer | bash >/dev/null 2>&1 & loading_animation "Installing Symfony"
    sudo mv $HOME/.symfony5/bin/symfony /usr/local/bin/symfony

    echo -e "\e[32mSymfony installed successfully.\e[0m"
}

remove_symfony() {
    if check_command symfony; then
        sudo rm /usr/local/bin/symfony & loading_animation "Removing Symfony"
    fi

    echo -e "\e[32mSymfony removed successfully.\e[0m"
}

#========================================================SYMFONY END========================================================#





#========================================================NVM START========================================================#

check_nvm_is_installed(){
    if [ -n "$NVM_DIR" ] && [[ -s $NVM_DIR/nvm.sh ]]; then
        return 0
    fi
    return 1
}

display_nvm_status(){
    if check_nvm_is_installed; then
        echo -e "\e[32mNVM is already installed.\e[0m"
    else
        echo -e "\e[31mNVM is not installed.\e[0m"
    fi
}

install_nvm() {
    install_dependency "curl"

    if [ -n "$NVM_DIR" ] && [[ -s $NVM_DIR/nvm.sh ]]; then
        echo -e "\e[32mNVM is already installed.\e[0m"
    else
        curl -sS https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash >/dev/null 2>&1 & loading_animation "Installing NVM"
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi
}

remove_nvm() {
    if check_nvm_is_installed; then
        echo "Removing NodeJs before NVM..."

        if check_node_is_installed; then
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            installed_node_versions=($(ls $HOME/.nvm/versions/node/))

            if [ ${#installed_node_versions[@]} -ne 0 ]; then
                for version in "${installed_node_versions[@]}"; do
                    nvm uninstall "$version" >/dev/null 2>&1 & loading_animation "Removing NodeJs $version"
                done
            fi
        fi

        echo -e "\e[32mNodeJs removed successfully.\e[0m"

        echo "Removing NVM..."

        sed -i '/export NVM_DIR="\$HOME\/.nvm"/,+2d' $HOME/.bashrc

        if [ -d "$HOME/.nvm" ]; then
            rm -rf $HOME/.nvm && loading_animation "Removing NVM"
        fi

        exec bash

        echo -e "\e[32mNVM removed successfully.\e[0m"
    fi
}

#========================================================NVM END========================================================#





#========================================================NODEJS START========================================================#

check_node_is_installed(){
    if [ ! -d "$HOME/.nvm/versions/node/" ]; then
        return 1
    fi
    return 0
}

display_node_status() {
    if ! check_node_is_installed; then
        echo -e "\e[31mNodeJs is not installed.\e[0m"
        return
    fi

    installed_node_versions=($(ls "$HOME/.nvm/versions/node/"))

    if [ ${#installed_node_versions[@]} -eq 0 ]; then
        echo -e "\e[31mNo NodeJs versions are installed.\e[0m"
        return
    fi

    for version in "${installed_node_versions[@]}"; do
        echo -e "\e[32mNodeJs $version is installed.\e[0m"
    done
}

install_node() {
    if [ -n "$NVM_DIR" ] && [[ -s $NVM_DIR/nvm.sh ]]; then
        echo -e "\e[32mNVM is already installed.\e[0m"
    else
        install_nvm
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    read -p "Enter NodeJs version(s) to install (comma-separated, e.g., node, 19.9.0, 10.24.1) (node is for latest): " node_versions
    IFS=',' read -ra node_versions_array <<< "$node_versions" 

    for version in "${node_versions_array[@]}"; do
        displayVersion=$version
        if [ "$version" = "node" ]; then
            displayVersion="latest"
        fi
        nvm install "$version" >/dev/null 2>&1 & loading_animation "Installing NodeJs $displayVersion"
    done
}

remove_node(){
    if check_node_is_installed; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        read -p "Enter NodeJs version(s) to remove (comma-separated, e.g., 23.4.0, 19.9.0, 10.24.1) (do not use node for latest): " node_versions
        IFS=',' read -ra node_versions_array <<< "$node_versions"

        for version in "${node_versions_array[@]}"; do
            nvm uninstall "$version" >/dev/null 2>&1 & loading_animation "Removing NodeJs $version"
        done

        echo -e "\e[32mNodeJs removed successfully.\e[0m"
    fi
}

#========================================================NODEJS END========================================================#





#========================================================ALL FUNCTIONS START========================================================#

install_all() {
    full_install_php
    install_composer
    install_symfony
    install_nvm
    install_node
    sleep 2
}

display_tools(){
    display_php_status
    display_composer_status
    display_symfony_status
    display_nvm_status
    display_node_status
}

#========================================================ALL FUNCTIONS END========================================================#





#========================================================MENU START========================================================#

clean_install=false

display_menu() {
    local options=( "Clean Install" "Install NVM" "Install NodeJs" "Install Symfony" "Install Composer" "Install PHP" "Install All" "Quit")
    local selected=0

    draw_menu() {
        tput cup 0 0
        display_tools
        echo "Use the arrow keys to navigate and Enter to select:"

        for i in "${!options[@]}"; do
            if [ $i -eq $selected ]; then
                if [ $i -eq 0 ]; then
                    if $clean_install; then
                        clean_install_display="[x]"
                    else
                        clean_install_display="[ ]"
                    fi
                    echo -e "\e[1;34m> ${options[$i]} $clean_install_display\e[0m"
                else
                    echo -e "\e[1;34m> ${options[$i]}\e[0m"
                fi
            else
                if [ $i -eq 0 ]; then
                    if $clean_install; then
                        clean_install_display="[x]"
                    else
                        clean_install_display="[ ]"
                    fi
                    echo "  ${options[$i]} $clean_install_display"
                else
                    echo "  ${options[$i]}"
                fi
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
                    "Clean Install")
                        if $clean_install; then
                            clean_install=false
                        else
                            clean_install=true
                        fi
                        tput civis
                        draw_menu
                        continue
                        ;;
                    "Install NVM")
                         if $clean_install; then
                                echo "Clean Install of NVM"
                                remove_nvm
                                install_nvm
                                echo -e "\e[32mNVM clean installation complete.\e[0m"
                           else
                                install_nvm
                            echo -e "\e[32mNVM installation complete.\e[0m"
                        fi
                        ;;
                    "Install Symfony")
                        if $clean_install; then
                                echo "Clean Install of Symfony"
                                remove_symfony
                                install_symfony
                                echo -e "\e[32mSymfony clean installation complete.\e[0m"
                           else
                                install_symfony
                            echo -e "\e[32mSymfony installation complete.\e[0m"
                            fi
                        ;;
                    "Install NodeJs")
                        if $clean_install; then
                                echo "Clean Install of NodeJs"
                                remove_node
                                install_node
                                echo -e "\e[32mNodeJs clear installation complete.\e[0m"
                           else
                                install_node
                            echo -e "\e[32mNodeJs installation complete.\e[0m"
                            fi
                        ;;
                    "Install Composer")
                       if $clean_install; then
                                echo "Clean Install of Composer"
                                remove_composer
                                install_composer
                                echo -e "\e[32mComposer clean installation complete.\e[0m"
                           else
                                install_composer
                            echo -e "\e[32mComposer installation complete.\e[0m"
                            fi
                        ;;
                    "Install PHP")
                        if $clean_install; then
                                echo "Clean Install of PHP"
                                remove_php
                                full_install_php
                                echo -e "\e[32mPHP clean installation complete.\e[0m"
                           else
                               full_install_php
                                echo -e "\e[32mPHP installation complete.\e[0m"
                            fi
                        ;;
                    "Install All")
                       if $clean_install; then
                                echo "Clean Install of All"
                                remove_php
                                remove_nvm
                                install_all
                                echo -e "\e[32mAll clean installation complete.\e[0m"
                           else
                                install_all
                                echo -e "\e[32mAll installation complete.\e[0m"
                           fi
                        ;;
                    "Quit")
                        echo "Goodbye!"
                        tput cnorm
                        rm "$0" & exit
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

display_menu

#========================================================MENU END========================================================#