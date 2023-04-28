# Fluent theme

Fluent is a Fluent design theme for GNOME/GTK based desktop environments. See also [Fluent Icon theme](https://github.com/vinceliuice/Fluent-icon-theme).

### Normal version
![screenshot01](https://github.com/vinceliuice/Fluent-gtk-theme/blob/Images/screenshot01.png?raw=true)

### Blur version (Only for Gnome-Shell desktop)
![screenshot-blur](https://github.com/vinceliuice/Fluent-gtk-theme/blob/Images/screenshot-blur.jpg?raw=true)

#### Blur version requirement

- [Blur My Shell](https://github.com/aunetx/blur-my-shell)

## Requirements

- GTK `>=3.20`
- `gnome-themes-extra` (or `gnome-themes-standard`)
- Murrine engine — The package name depends on the distro.
  - `gtk-engine-murrine` on Arch Linux
  - `gtk-murrine-engine` on Fedora
  - `gtk2-engine-murrine` on openSUSE
  - `gtk2-engines-murrine` on Debian, Ubuntu, etc.
- `sassc` — build dependency

## Installation

### Manual Installation

Run the following commands in the terminal:

```sh
./install.sh
```

> Tip: `./install.sh` allows the following options:

```
-d, --dest DIR          Specify destination directory (Default: /usr/share/themes)

-n, --name NAME         Specify theme name (Default: Fluent)

-t, --theme VARIANT     Specify theme color variant(s) [default|purple|pink|red|orange|yellow|green|grey|teal|all] (Default: blue)

-c, --color VARIANT     Specify color variant(s) [standard|light|dark] (Default: All variants)

-s, --size VARIANT      Specify size variant [standard|compact] (Default: All variants)

-i, --icon VARIANT      Specify icon variant(s) for shell panel
                        [default|apple|simple|gnome|ubuntu|arch|manjaro|fedora|debian|void|opensuse|popos|mxlinux|zorin|endeavouros|tux|nixos]
                        (Default: Windows icon)

-l, --libadwaita        Install link to gtk4 config for theming libadwaita

-u, --uninstall         Uninstall themes or link for libadwaita

--tweaks                Specify versions for tweaks [solid|float|round|blur|noborder|square]
                        solid:    no transparency version
                        float:    floating panel
                        round:    rounded windows
                        blur:     blur version for 'Blur-Me'
                        noborder: windows and menu with no border
                        square:   square windows button

-h, --help              Show help
```

![theme-view](https://github.com/vinceliuice/Fluent-gtk-theme/blob/Images/theme-view.png?raw=true)

> For more information, run: `./install.sh --help`

### Flatpak Installation

Automatically install your host GTK+ theme as a Flatpak.

- [pakitheme](https://github.com/refi64/pakitheme)

### Wallpaper
[Install Wallpapers](https://github.com/vinceliuice/Fluent-gtk-theme/tree/Wallpaper)

#### Preview
![wallpaper](https://github.com/vinceliuice/Fluent-gtk-theme/blob/Images/wallpaper-view.png?raw=true)

### Firefox theme
[Install Firefox theme](src/firefox)

#### Preview
![firefox-view](https://github.com/vinceliuice/Fluent-gtk-theme/blob/Images/firefox-view.png?raw=true)

### Fix for Dash to panel

Just install the compact version

```sh
./install.sh --tweaks compact
```

## Gtk theme widgets
![screenshot02](https://github.com/vinceliuice/Fluent-gtk-theme/blob/Images/screenshot02.png?raw=true)
