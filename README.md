# 🚀 **Supercharge Your Development Environment with DDES!** 🚀

## ✨ **Effortlessly install PHP, Composer, Symfony, NVM, and NodeJs with our automated script!** ✨

![stable](https://img.shields.io/badge/Stable%20Version-1.4-blue)
![indev](https://img.shields.io/badge/InDev%20Version-1.5-red)

## Test with Docker 🐳

```bash
docker build -t ubuntu-ddes-image .
docker-compose up -d
docker-compose exec ubuntu-ddes bash
```

### One-line command for the speedy developer 💨

```bash
docker build -t ubuntu-ddes-image . && docker-compose up -d --force-recreate && docker-compose exec ubuntu-ddes bash
```

## Use the latest stable release 🏷️

```bash
wget https://raw.githubusercontent.com/AxelRhul/ddes/v1.4/ddes.sh && chmod +x ddes.sh && ./ddes.sh && source ~/.bashrc
```

## Use the bleeding edge (indev) version 🧪

```bash
git clone https://github.com/AxelRhul/ddes.git && git checkout -m indev && cd ddes/ && chmod +x ddes.sh && ./ddes.sh && source ~/.bashrc
```

## Feature-packed Menu 🧰

- **Clear Install Checkbox:**  🗑️  Wipe away old installations and start fresh!
- **Install PHP:**  🐘  Choose your desired PHP version.
- **Install Composer:** 🎼  Orchestrate your project dependencies.
- **Install Symfony:** 🗼  Build elegant and robust web applications.
- **Install NVM:**  🔄  Effortlessly manage Node.js versions.
- **Install NodeJs:**  🟩  Power your JavaScript development.
- **Install All:**  🚀  Get everything you need in one go!
- **Quit:**  🚪  Exit the script and remove the script.

## Additional Perks 🎉

- **Customize PHP and NodeJs versions:**  Pick the perfect tools for your project.
- **Automatic dependency checks:**  ✅  Ensures a smooth installation process.
- **Interactive menu:**  🖱️  Easily navigate and select your desired installations.

## Contribute and Make DDES Even Better! 🤝

Found a bug ? 🐛  

Have an awesome idea? 💡  

Open an issue or submit a pull request !

## License 📜

This project is licensed under the MIT License - see the [license](LICENCE.md) file for details.
