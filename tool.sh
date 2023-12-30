#!/bin/bash

# Array to store installed PHP versions
installed_php_versions=()

check_command() {
    command -v $1 >/dev/null 2>&1
}


display_tool_status() {
    if check_command $1; then
        echo -e "\e[32m$1 is already installed.\e[0m"
    else
        echo -e "\e[31m$1 is not installed.\e[0m"
    fi
}

# Function to display PHP version status in color
# Function to display PHP version status in color
display_php_status() {
    # Check if /etc/php/ directory exists
    if [ ! -d "/etc/php/" ]; then
        echo -e "\e[31mPHP is not installed.\e[0m"
        return
    fi

    # Get the list of installed PHP versions
    installed_php_versions=($(ls /etc/php/))

    if [ ${#installed_php_versions[@]} -eq 0 ]; then
        echo -e "\e[31mNo PHP versions are installed.\e[0m"
        return
    fi

    for version in "${installed_php_versions[@]}"; do
        echo -e "\e[32mPHP $version is installed.\e[0m"
    done
}



if ! command -v sudo &>/dev/null; then
  echo "sudo is not installed. Installing it with apt..."
  apt-get update
  apt-get install sudo -y
fi

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

# Variable to control the loop
should_exit=false

pre_install_php() {
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt-get update -y
}

install_php() {
    version=$1
    sudo apt-get install php$version php$version-fpm php$version-mysql libapache2-mod-php$version libapache2-mod-fcgid -y
    sudo apt-get install -y php php-cli php-common php-fpm php-mysql php-zip php-gd php-mbstring php-curl php-xml php-bcmath openssl php-json php-tokenizer php-intl
    installed_php_versions+=("$version")
}

install_dependency() {
    command -v $1 >/dev/null 2>&1 || sudo apt install -y $1
}

install_composer() {
    install_dependency "curl"

    if [ ! -d "/etc/php/" ]; then
        echo "PHP is not installed. Installing PHP..."
        pre_install_php
        read -p "Enter PHP version(s) to install (comma-separated, e.g., 7.4,8.0): " php_versions
        IFS=',' read -ra php_versions_array <<< "$php_versions"  # Split the input into an array

        for version in "${php_versions_array[@]}"; do
            install_php "$version"
        done
    fi
    
    if ! command -v composer &>/dev/null; then
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php composer-setup.php --install-dir=/usr/local/bin --filename=composer
        php -r "unlink('composer-setup.php');"
        echo "Composer installed successfully."
    else
        echo "Composer is already installed."
    fi
}

install_symfony() {
    install_dependency "curl" && install_dependency "git"

    if ! command -v composer &>/dev/null; then
        install_composer
    fi

    sudo wget https://get.symfony.com/cli/installer -O - | bash
    sudo mv $HOME/.symfony5/bin/symfony /usr/local/bin/symfony
}

install_nvm() {
    install_dependency "curl" && install_dependency "bash"

    command -v nvm >/dev/null 2>&1 || {
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    }
    source ~/.bashrc
}

install_all() {
    pre_install_php
    read -p "Enter PHP version(s) to install (comma-separated, e.g., 7.4,8.0): " php_versions
    IFS=',' read -ra php_versions_array <<< "$php_versions"  # Split the input into an array

    for version in "${php_versions_array[@]}"; do
        install_php "$version"
    done

    install_composer
    install_symfony
    install_nvm
}

display_tools

display_menu() {
    select option in "Install PHP" "Install Composer" "Install Symfony" "Install NVM" "Install All" "Quit"
    do
        case $option in
            "Install PHP")
                pre_install_php
                read -p "Enter PHP version(s) to install (comma-separated, e.g., 7.4,8.0): " php_versions
                IFS=',' read -ra php_versions_array <<< "$php_versions"  # Split the input into an array

                for version in "${php_versions_array[@]}"; do
                    install_php "$version"
                done
                sudo update-alternatives --config php
                echo -e "\e[32mPHP installation complete.\e[0m"
                echo "----------------------------------"
                display_tools
                echo "----------------------------------"
                echo "Select an option:"
                echo "1) Install PHP"
                echo "2) Install Composer"
                echo "3) Install Symfony"
                echo "4) Install NVM"
                echo "5) Install All"
                echo "6) Quit"
                ;;
            "Install Composer")
                install_composer
                echo -e "\e[32mComposer installation complete.\e[0m"
                echo "----------------------------------"
                display_tools
                echo "----------------------------------"
                echo "Select an option:"
                echo "1) Install PHP"
                echo "2) Install Composer"
                echo "3) Install Symfony"
                echo "4) Install NVM"
                echo "5) Install All"
                echo "6) Quit"
                ;;
            "Install Symfony")
                install_symfony
                echo -e "\e[32mSymfony installation complete.\e[0m"
                echo "----------------------------------"
                display_tools
                echo "----------------------------------"
                echo "Select an option:"
                echo "1) Install PHP"
                echo "2) Install Composer"
                echo "3) Install Symfony"
                echo "4) Install NVM"
                echo "5) Install All"
                echo "6) Quit"
                ;;
            "Install NVM")
                install_nvm
                echo -e "\e[32mNVM installation complete.\e[0m"
                echo "----------------------------------"
                display_tools
                echo "----------------------------------"
                echo "Select an option:"
                echo "1) Install PHP"
                echo "2) Install Composer"
                echo "3) Install Symfony"
                echo "4) Install NVM"
                echo "5) Install All"
                echo "6) Quit"
                ;;
            "Install All")
                install_all
                echo -e "\e[32mAll installation complete.\e[0m"
                echo "----------------------------------"
                display_tools
                echo "----------------------------------"
                echo "Select an option:"
                echo "1) Install PHP"
                echo "2) Install Composer"
                echo "3) Install Symfony"
                echo "4) Install NVM"
                echo "5) Install All"
                echo "6) Quit"
                ;;
            "Quit")
                echo "Goodbye!"
                should_exit=true
                exit 0
                ;;
            *)
                echo "Invalid option. Please choose a valid option."
                ;;
        esac
    done
}

display_menu
