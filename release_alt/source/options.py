#!/usr/bin/python3

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
gi.require_version('Gdk', '3.0')
from gi.repository import Gdk
from gi.repository import Gio, GLib
import json
import os
import subprocess
import string
import random
import time

'''
Dist, $XDG_CURRENT_DESKTOP, $XDG_SESSION_TYPE
Ubuntu 18.04,       ubuntu:GNOME,   x11,        rename theme.
Ubuntu 20.04,       ubuntu:GNOME,   x11,        rename theme.
Ubuntu 22.04,       ubuntu:GNOME,   x11,        rename theme.
Manjaro gnome 23    GNOME,          x11,        rename theme.
Fedora 39,          GNOME,          wayland,    ok
Ubuntu Unity 23     Unity:Unity7:ubuntu, x11    ok
xubuntu 23          XFCE,           x11,        ok
Manjaro xfce 22     XFCE,           x11,        ok
MX Linux 23.2       XFCE,           x11,
Manjaro Cinnamon    X-Cinnamon,     x11,        rename theme.
Manjaro Cinnamon    X-Cinnamon,     wayland,    ok
LinuxMint 21.3 mate MATE,           x11,        ok
elementaryos-7      Pantheon,       x11,        rename theme. Has no effect on gtk3 apps
popOS 22,           pop:GNOME,      x11,        rename theme.
Ubuntu Budgie 23    Budgie:GNOME,   x11,        rename theme and set org.gnome.desktop.interface
    color-scheme as it changes to "prefer-dark" each time.
'''
rename_theme_on_update = False
desktop_environment = os.environ.get('XDG_CURRENT_DESKTOP')
if not desktop_environment:
    desktop_environment = "Unknown"
elif "Budgie" in desktop_environment:
    desktop_environment = 'Budgie'
    rename_theme_on_update = True
elif "Unity" in desktop_environment:
    desktop_environment = 'Unity'
elif "pop" in desktop_environment:
    desktop_environment = 'pop'
    rename_theme_on_update = os.environ["XDG_SESSION_TYPE"] == "x11"
elif "ubuntu:GNOME" in desktop_environment:
    desktop_environment = 'ubuntu:GNOME'
    rename_theme_on_update = os.environ["XDG_SESSION_TYPE"] == "x11"
elif "GNOME" in desktop_environment:
    desktop_environment = 'GNOME'
    rename_theme_on_update = os.environ["XDG_SESSION_TYPE"] == "x11"
elif "Cinnamon" in desktop_environment:
    desktop_environment = "Cinnamon"
    rename_theme_on_update = os.environ["XDG_SESSION_TYPE"] == "x11"
elif "MATE" in desktop_environment:
    desktop_environment = "MATE"
elif "XFCE" in desktop_environment:
    desktop_environment = "XFCE"
elif "Pantheon" in desktop_environment:
    desktop_environment = "Pantheon"
    rename_theme_on_update = True

print(f"Desktop environment is: {desktop_environment}...")

class OptionsWindow(Gtk.Window):
    def __init__(self, desktop_environment, rename_theme_on_update):
        super().__init__(title="")

        self.desktop_environment = desktop_environment
        self.rename_theme_on_update = rename_theme_on_update

        self.current_theme_dir = os.path.dirname(os.path.abspath(__file__))
        self.current_theme_name = os.path.basename(self.current_theme_dir)
        
        self.set_default_size(500, 100)
        
        box = Gtk.Box.new(Gtk.Orientation.VERTICAL, 15)
        box.set_margin_top(20)
        box.set_margin_bottom(20)
        box.set_margin_start(35)
        box.set_margin_end(35)
        self.add(box)
        self.set_icon_name("applications-graphics")
        
        self.load_config_file()
        theme_name = self.options.get("theme_name", "?")
        self.set_title("%s theme options" % theme_name)
        
        self.widgets = {}
        
        for option in self.options["options"]:
            desktops = option["desktop"]
            if isinstance(desktops, str):
                desktops = [desktops]
            if not ("all" in desktops or self.desktop_environment in desktops):
                continue
            
            if option["type"] == "combo":
                combobox = Gtk.Box.new(Gtk.Orientation.HORIZONTAL, 10)
                combobox_label = Gtk.Label.new(option["label"])
                combobox_label.set_halign(Gtk.Align.START)
                combobox.pack_start(combobox_label, True, True, 0)
                combo_widget = Gtk.ComboBoxText.new()
                for label in option["labels"]:
                    combo_widget.append_text(label)
                combo_widget.set_active(option["value"])
                combo_widget.set_halign(Gtk.Align.END)
                combo_widget.connect("changed", self.on_setting_changed)
                combobox.pack_start(combo_widget, True, True, 0)
                box.pack_start(combobox, False, True, 0)
                self.widgets[option["name"]] = combo_widget
            elif option["type"] == "switch":
                switchbox = Gtk.Box.new(Gtk.Orientation.HORIZONTAL, 10)
                switchbox_label = Gtk.Label.new(option["label"])
                switchbox_label.set_halign(Gtk.Align.START)
                switchbox.pack_start(switchbox_label, True, True, 0)
                switch = Gtk.Switch.new()
                switch.set_active(option["value"])
                switch.set_halign(Gtk.Align.END)
                switch.set_valign(Gtk.Align.CENTER)
                switch.connect("state-set", self.on_setting_changed)
                switchbox.pack_start(switch, True, True, 0)
                box.pack_start(switchbox, False, True, 0)
                self.widgets[option["name"]] = switch
            elif option["type"] == "color-chooser":
                colorbox = Gtk.Box.new(Gtk.Orientation.HORIZONTAL, 10)
                colorbox_label = Gtk.Label.new(option["label"])
                colorbox_label.set_halign(Gtk.Align.START)
                colorbox.pack_start(colorbox_label, True, True, 0)
                colorButton = Gtk.ColorButton.new()
                color = Gdk.RGBA()
                color.parse(option["value"])
                colorButton.set_rgba(color)
                colorButton.set_halign(Gtk.Align.END)
                colorButton.set_valign(Gtk.Align.CENTER)
                colorButton.connect("color-set", self.on_setting_changed)
                colorbox.pack_start(colorButton, True, True, 0)
                box.pack_start(colorbox, False, True, 0)
                self.widgets[option["name"]] = colorButton
            elif option["type"] == "spinbutton":
                spinbox = Gtk.Box.new(Gtk.Orientation.HORIZONTAL, 10)
                spinbox_label = Gtk.Label.new(option["label"])
                spinbox_label.set_halign(Gtk.Align.START)
                spinbox.pack_start(spinbox_label, True, True, 0)
                spinbutton = Gtk.SpinButton.new_with_range(option["min"],option["max"],option["step"])
                spinbutton.set_value(option["value"])
                spinbutton.set_snap_to_ticks(True)
                spinbutton.set_halign(Gtk.Align.END)
                spinbutton.set_valign(Gtk.Align.CENTER)
                spinbutton.connect("changed", self.on_setting_changed)
                spinbox.pack_start(spinbutton, True, True, 0)
                box.pack_start(spinbox, False, True, 0)
                self.widgets[option["name"]] = spinbutton
        #---------------------------
        if len(self.widgets) > 0:
            xfwm_dir = os.path.join(self.current_theme_dir, "xfwm4")
            if (self.desktop_environment == "XFCE" and os.path.exists(xfwm_dir)):
                label = Gtk.Label.new("For title bar changes, ensure 'Set matching Xfwm4 theme'"\
                   " in Appearance settings is checked.")
                label.set_line_wrap(True)
                label.set_size_request(450, -1)
                box.pack_start(label, False, True, 0)
            #---------------------------
            self.applybutton = Gtk.Button.new_with_label("Apply")
            self.applybutton.set_halign(Gtk.Align.CENTER)
            self.applybutton.set_valign(Gtk.Align.END)
            self.applybutton.set_sensitive(False)
            self.applybutton.connect("clicked", self.on_apply_button_clicked)
            box.pack_start(self.applybutton, False, True, 0)
            #---------------------------
            separator = Gtk.Separator.new(Gtk.Orientation.HORIZONTAL)
            separator.set_valign(Gtk.Align.END)
            box.pack_start(separator, False, True, 0)
        #---------------------------
        setthemebox = Gtk.Box.new(Gtk.Orientation.HORIZONTAL, 10)
        self.setthemebox_label = Gtk.Label.new("")
        self.setthemebox_label.set_halign(Gtk.Align.START)
        setthemebox.pack_start(self.setthemebox_label, True, True, 0)
        self.setthemebox_button = Gtk.Button.new()
        self.setthemebox_button.set_label("Set theme")
        self.setthemebox_button.set_halign(Gtk.Align.END)
        self.setthemebox_button.set_valign(Gtk.Align.CENTER)
        self.setthemebox_button.connect("clicked", self.on_setthemebox_button_clicked)
        setthemebox.pack_start(self.setthemebox_button, True, True, 0)
        box.pack_start(setthemebox, False, True, 0)
        self.update_setthemebox()
        #---------------------------
        if self.options.get("adwaita_link_to_gtk4", False):
            adwaitabox = Gtk.Box.new(Gtk.Orientation.HORIZONTAL, 10)
            self.adwaitabox_label = Gtk.Label.new("")
            self.adwaitabox_label.set_halign(Gtk.Align.START)
            adwaitabox.pack_start(self.adwaitabox_label, True, True, 0)
            self.adwaitabox_button = Gtk.Button.new()
            self.adwaitabox_button.set_halign(Gtk.Align.END)
            self.adwaitabox_button.set_valign(Gtk.Align.CENTER)
            self.adwaitabox_button.connect("clicked", self.on_adwaitabox_button_clicked)
            adwaitabox.pack_start(self.adwaitabox_button, True, True, 0)
            box.pack_start(adwaitabox, False, True, 0)
            self.update_adwaitabox()

    def update_adwaitabox(self):
        if is_libadwaita_linked(self.current_theme_dir):
            self.adwaitabox_label.set_text("This theme is your current libadwaita theme")
            self.adwaitabox_button.set_label("Remove")
        else:
            self.adwaitabox_label.set_text("Set this theme as your current libadwaita theme")
            self.adwaitabox_button.set_label("Install")

    def on_adwaitabox_button_clicked(self, button):
        if is_libadwaita_linked(self.current_theme_dir): # "Remove" clicked
            unlink_libadwaita()
        else: # "Install" clicked
            unlink_libadwaita()
            link_libadwaita(self.current_theme_dir)

        self.update_adwaitabox()
    
    def update_setthemebox(self):
        if is_current_theme(self.current_theme_name):
            self.setthemebox_label.set_text("This theme is your current desktop theme")
            self.setthemebox_button.set_sensitive(False)
        else:
            self.setthemebox_label.set_text("This theme is not your current desktop theme")
            self.setthemebox_button.set_sensitive(True)

    def on_setthemebox_button_clicked(self, button):
        set_theme(self.current_theme_name)
        self.update_setthemebox()

    def on_setting_changed(self, *args):
        self.applybutton.set_sensitive(True)

    def load_config_file(self):
        file_name = os.path.join(self.current_theme_dir, "config", "options_config.json")
        with open(file_name, "r") as file:
            self.options = json.load(file)

    def save_config_file(self, new_theme_dir):
        file_name = os.path.join(new_theme_dir, "config", "options_config.json")
        with open(file_name, "w") as file:
            json.dump(self.options, file, indent=4)

    def get_new_theme_names(self):
        if self.rename_theme_on_update:
            random_chars = "".join(random.choices(string.digits, k=3))
            new_theme_name = self.options["theme_name"] + random_chars
            new_theme_dir = os.path.join(os.path.dirname(self.current_theme_dir), new_theme_name)
            print ("Renaming theme to " + new_theme_name + "...")
        else: #keep same name
            new_theme_dir = self.current_theme_dir
            new_theme_name = self.current_theme_name
        return (new_theme_dir, new_theme_name)

    def on_apply_button_clicked(self, button):        
        new_theme_dir, new_theme_name = self.get_new_theme_names()
        #Rename theme directory if neccessary
        if new_theme_dir != self.current_theme_dir:
            os.rename(self.current_theme_dir, new_theme_dir)

        #prepare install command and store settings
        command = [os.path.join(new_theme_dir, 'config', self.options["script_name"])]
        
        for option in self.options["options"]:
            desktops = option["desktop"]
            if isinstance(desktops, str):
                desktops = [desktops]
            if "all" in desktops or self.desktop_environment in desktops:
                if option["type"] == "combo":
                    command.append("--" + option["name"])
                    value = self.widgets[option["name"]].get_active()
                    option["value"] = value
                    value_id = option["ids"][value]
                    command.append(value_id)
                elif option["type"] == "switch":
                    value = self.widgets[option["name"]].get_active()
                    option["value"] = value
                    if value:
                        command.append("--" + option["name"])
                elif option["type"] == "color-chooser":
                    command.append("--" + option["name"])
                    rgba = self.widgets[option["name"]].get_rgba()
                    red = int(round(rgba.red * 255))
                    green = int(round(rgba.green * 255))
                    blue = int(round(rgba.blue * 255))
                    value = f"#{red:02x}{green:02x}{blue:02x}"
                    option["value"] = value
                    command.append(value)
                elif option["type"] == "spinbutton":
                    command.append("--" + option["name"])
                    value = self.widgets[option["name"]].get_value()
                    if value == int(value):
                        value = int(value)
                    option["value"] = value
                    command.append(str(value))
        
        #Install theme
        print ("Running..." + " ".join(command))
        subprocess.run(command, check=True)
        print("Install finished OK")
        
        #save settings
        self.save_config_file(new_theme_dir)

        #apply desktop theme
        update_theme(self.current_theme_name, new_theme_name)
        self.applybutton.set_sensitive(False)

        #Relink libadwaita if neccessary
        if new_theme_name != self.current_theme_name and is_libadwaita_linked(self.current_theme_dir):
            unlink_libadwaita()
            link_libadwaita(new_theme_dir)

        #update theme name
        self.current_theme_dir = new_theme_dir
        self.current_theme_name = new_theme_name

def is_link_to(link, target):
    return os.path.islink(link) and os.readlink(link) == target

def is_libadwaita_linked(theme_dir):
    config_dir = os.path.expanduser('~/.config/gtk-4.0/')
    return (is_link_to(os.path.join(config_dir, 'assets'), os.path.join(theme_dir, 'gtk-4.0', 'assets')) and
        is_link_to(os.path.join(config_dir, 'gtk.css'), os.path.join(theme_dir, 'gtk-4.0', 'gtk.css')) and
        is_link_to(os.path.join(config_dir, 'gtk-dark.css'), os.path.join(theme_dir, 'gtk-4.0', 'gtk-dark.css')))

def link_libadwaita(theme_dir):
    config_dir = os.path.expanduser('~/.config/gtk-4.0/')
    os.makedirs(config_dir, exist_ok=True)
    os.symlink(os.path.join(theme_dir, 'gtk-4.0', 'assets'), os.path.join(config_dir, 'assets'), target_is_directory = True)
    os.symlink(os.path.join(theme_dir, 'gtk-4.0', 'gtk.css'), os.path.join(config_dir, 'gtk.css'))
    os.symlink(os.path.join(theme_dir, 'gtk-4.0', 'gtk-dark.css'), os.path.join(config_dir, 'gtk-dark.css'))
               
def unlink_libadwaita():
    config_dir = os.path.expanduser('~/.config/gtk-4.0/')
    subprocess.run(["rm", "-rf", config_dir + "assets"])
    subprocess.run(["rm", "-rf", config_dir + "gtk.css"])
    subprocess.run(["rm", "-rf", config_dir + "gtk-dark.css"])

#---------------------------------------------------

def gsettings_get(schema, key):
    if Gio.SettingsSchemaSource.get_default().lookup(schema, True) is not None:
        setting = Gio.Settings.new(schema)
        return setting.get_string(key)
    else:
        return ""

def gsettings_set(schema, key, value):
    if Gio.SettingsSchemaSource.get_default().lookup(schema, True) is not None:
        print ("gsettings setting " + schema + " " + key + " " + value)
        setting = Gio.Settings.new(schema)
        setting.set_string(key, value)

def xfconf_get(channel, key):
    try:
        command = ["xfconf-query", "-c", channel, "-p", key]
        output = subprocess.check_output(command, text=True)
    except Exception as e:
        print("xfconf-query error: ", e)
        output = ""
    return output.rstrip("\n")

def xfconf_set(channel, key, value):
    try:
        print ("xfconf-query setting ", channel, key, value)
        subprocess.run(["xfconf-query", "-c", channel, "-p", key, "-s", value])
    except Exception as e:
        print("xfconf-query error: ", e)

def xfconf_reset(channel, key):
    try:
        print ("xfconf-query resetting ", channel, key)
        subprocess.run(["xfconf-query", "-c", channel, "-p", key, "-r"])
    except Exception as e:
        print("xfconf-query error: ", e)

def is_current_theme(current_theme_name):
    if desktop_environment in {"GNOME", "ubuntu:GNOME", "pop", "Pantheon", "Budgie", "Unity"}:
        return gsettings_get("org.gnome.desktop.interface",
                                        "gtk-theme") == current_theme_name
    elif desktop_environment == "Cinnamon":
        return gsettings_get("org.cinnamon.desktop.interface",
                                        "gtk-theme") == current_theme_name
        #return gsettings_get("org.cinnamon.theme", "name") == current_theme_name
    elif desktop_environment == "XFCE":
        return xfconf_get("xsettings", "/Net/ThemeName") == current_theme_name
    elif desktop_environment == "MATE":
        return gsettings_get("org.mate.interface", "gtk-theme") == current_theme_name

def set_theme(theme_name):
    if desktop_environment in {"ubuntu:GNOME", "GNOME", "pop", "Pantheon"}:
        gsettings_set("org.gnome.desktop.interface", "gtk-theme", theme_name)
    elif desktop_environment == "Cinnamon":
        gsettings_set("org.cinnamon.desktop.interface", "gtk-theme", theme_name)
    elif desktop_environment == "XFCE":
        xfconf_set("xsettings", "/Net/ThemeName", theme_name)
        #xfconf_set("xfwm4", "/general/theme", current_theme_name, reload_only)
    elif desktop_environment == "MATE":
            gsettings_set("org.mate.interface", "gtk-theme", theme_name)
    elif desktop_environment == "Budgie":
        setting = Gio.Settings.new("org.gnome.desktop.interface")
        current_color_scheme = setting.get_string("color-scheme")
        gsettings_set("org.gnome.desktop.interface", "gtk-theme", theme_name)
        time.sleep(1)
        setting.set_string("color-scheme", current_color_scheme)
    elif desktop_environment == "Unity":
        gsettings_set("org.gnome.desktop.interface", "gtk-theme", theme_name)
        gsettings_set("org.gnome.desktop.wm.preferences", "theme", theme_name)

def update_theme(current_theme_name, new_theme_name):
    if desktop_environment in {"ubuntu:GNOME", "GNOME", "pop", "Pantheon"}:
        if gsettings_get("org.gnome.desktop.interface", "gtk-theme") == current_theme_name:
            if current_theme_name == new_theme_name:
                gsettings_set("org.gnome.desktop.interface", "gtk-theme", "")
            gsettings_set("org.gnome.desktop.interface", "gtk-theme", new_theme_name)

    elif desktop_environment == "Cinnamon":
        def reset_cinnamon_theme():
            if current_theme_name == new_theme_name:
                gsettings_set("org.cinnamon.theme", "name", "")
            gsettings_set("org.cinnamon.theme", "name", new_theme_name)
            return False

        if gsettings_get("org.cinnamon.desktop.interface", "gtk-theme") == current_theme_name:
            if current_theme_name == new_theme_name:
                gsettings_set("org.cinnamon.desktop.interface", "gtk-theme", "")
            gsettings_set("org.cinnamon.desktop.interface", "gtk-theme", new_theme_name)

            if gsettings_get("org.cinnamon.theme", "name") == current_theme_name:
                GLib.timeout_add_seconds(1, reset_cinnamon_theme)
        elif gsettings_get("org.cinnamon.theme", "name") == current_theme_name:
            reset_cinnamon_theme()

    elif desktop_environment == "XFCE":
        if xfconf_get("xsettings", "/Net/ThemeName") == current_theme_name:
            xfconf_reset("xsettings", "/Net/ThemeName")
            xfconf_set("xsettings", "/Net/ThemeName", new_theme_name)
        #xfconf_set("xfwm4", "/general/theme", current_theme_name, reload_only)

    elif desktop_environment == "MATE":
        def set_mate_theme():
            gsettings_set("org.mate.interface", "gtk-theme", new_theme_name)
            return False
            
        if gsettings_get("org.mate.interface", "gtk-theme") == current_theme_name:
            gsettings_set("org.mate.interface", "gtk-theme", "")
            GLib.timeout_add_seconds(1, set_mate_theme)

    elif desktop_environment == "Budgie":
        if gsettings_get("org.gnome.desktop.interface", "gtk-theme") == current_theme_name:
            setting = Gio.Settings.new("org.gnome.desktop.interface")
            current_color_scheme = setting.get_string("color-scheme")
            if current_theme_name == new_theme_name:
                gsettings_set("org.gnome.desktop.interface", "gtk-theme", "")
            gsettings_set("org.gnome.desktop.interface", "gtk-theme", new_theme_name)
            time.sleep(1)
            setting.set_string("color-scheme", current_color_scheme)
            
    elif desktop_environment == "Unity":
        if gsettings_get("org.gnome.desktop.interface", "gtk-theme") == current_theme_name:
            if current_theme_name == new_theme_name:
                gsettings_set("org.gnome.desktop.interface", "gtk-theme", "")
                gsettings_set("org.gnome.desktop.wm.preferences", "theme", "")
            gsettings_set("org.gnome.desktop.interface", "gtk-theme", new_theme_name)
            gsettings_set("org.gnome.desktop.wm.preferences", "theme", new_theme_name)
    
if __name__ == "__main__":
    Gtk.init()

    win = OptionsWindow(desktop_environment, rename_theme_on_update)
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()  
