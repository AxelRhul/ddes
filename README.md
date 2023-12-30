# Default Development Environment Script (DDES)

## Test with Docker

```bash
docker-compose up -d
docker-compose exec ubuntu-ddes bash
apt update && apt install wget -y && apt install git -y
```

## Use the release

```bash
wget https://raw.githubusercontent.com/AxelRhul/ddes/v1/tool.sh && bash tool.sh && sudo rm -f tool.sh
```

## Use the indev

```bash
git clone https://github.com/AxelRhul/ddes.git && cd ddes/ && bash tool.sh 
```

## Follow the on-screen prompts to install PHP, Composer, Symfony, NVM, or all of them:

- Install PHP: Choose this option to install specific PHP versions.

- Install Composer: Installs Composer globally on your system.

- Install Symfony: Installs the Symfony CLI.

- Install NVM: Installs Node Version Manager (NVM).

- Install All: Installs PHP, Composer, Symfony, and NVM.

- Quit: Exits the script.

Enjoy the automated installation process for your development environment!

## Additional Information
You can customize the PHP versions you want to install during the script execution.

The script automatically checks for the presence of required dependencies and installs them if needed.

After each installation, the main menu is displayed, allowing you to choose additional tools or exit the script.

## Contributing
If you'd like to contribute to this project, feel free to open an issue or submit a pull request.

## License
This project is licensed under the MIT License - see the [license](LICENCE.md) file for details.

