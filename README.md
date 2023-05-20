# 🍓 Xila berry software

This repository is a template for [Xila berry software]().

## 📖 Table of contents

- [Installation](#installation)
- [Use](#use)
- [Structure](#structure)

## 📥 Installation

1. Create a new repository from this template.

2. Clone (recursively) your new repository : `git clone --recursive <URL>`

3. Install [Berry](https://github.com/berry-lang/berry) interpreter / compiler on your computer :
    
    - Linux (Debian) :
        - `sudo apt install libreadline-dev`
        - `cd Berry`
        - `make`
        - `make install`
    - Windows :
        - `cd Berry`
        - `make`
    - MacOS :
        - `brew install readline`
        - `cd Berry`
        - `make`
        - `make install` 

*Official installation steps can be found [here](https://github.com/berry-lang/berry).*

## ⌨️ Use

- You can compile your software using the following command : `berry -c Main.be` (or `./Berry/berry -c Main.berry` on Windows).

- Once you have written your software, you can copy the folder to your Xila installation, in the `/Software/` folder. You can also rename the folder since it is used as the software name.

Please note that Berry compiler is currently only used for checking the syntax of the software, since it's hard to debug a software on Xila. The compiled bytecode is not necessary (but not useless / disturbing) since Xila can compile the software itself.

## 📂 Structure

- `Code` : Contains the source code of the software.
- `Berry` : Contains the sources of berry interpreter.

