#!/usr/bin/python3

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from gi.repository import Gio
import json
import os
import subprocess
import string
import random
import time

'''
$XDG_CURRENT_DESKTOP values:
Cinnamon: "X-Cinnamon"
GNOME: "GNOME"
MATE: "MATE"
XFCE: "XFCE"
pop: "pop:GNOME"
Pantheon: "Pantheon"

Desktops:
GNOME, XFCE (xubuntu 23, Manjaro xfce 22), MATE, Unity (Ubuntu Unity 23): Works OK
Cinnamon, Pantheon (elementaryos-7): Works OK, but don't know how to update wm
    theme without renaming theme
pop (popOS 22): Treat as GNOME but doesn't seem to affect some gtk3 apps or wm
    theme (and neither does GNOME tweaks)
Budgie (Ubuntu Budgie 23): Works OK, but don't know how to update wm theme without
    renaming theme and have to set org.gnome.desktop.interface color-scheme as it changes
    to "prefer-dark" each time.
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
elif "GNOME" in desktop_environment:
    desktop_environment = 'GNOME'
elif "Cinnamon" in desktop_environment:
    desktop_environment = "Cinnamon"
    rename_theme_on_update = True
elif "MATE" in desktop_environment:
    desktop_environment = "MATE"
elif "XFCE" in desktop_environment:
    desktop_environment = "XFCE"
elif "Pantheon" in desktop_environment:
    desktop_environment = "Pantheon"
    rename_theme_on_update = True
else:
    desktop_environment = "Unknown"

print(f"Desktop environment is: {desktop_environment}...")

class OptionsWindow(Gtk.Window):
    def __init__(self, desktop_environment, rename_theme_on_update):
        super().__init__(title="")

        self.desktop_environment = desktop_environment
        self.rename_theme_on_update = rename_theme_on_update

        self.current_theme_dir = os.path.dirname(os.path.abspath(__file__))
        self.current_theme_name = os.path.basename(self.current_theme_dir)
        
        self.set_default_size(500, 100)
        
        box = Gtk.Box.new(Gtk.Orientation.VERTICAL, 5)
        box.set_margin_top(15)
        box.set_margin_bottom(15)
        box.set_margin_start(25)
        box.set_margin_end(25)
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
            if "all" in desktops or self.desktop_environment in desktops:
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
                    combo_widget.connect("changed", self.on_combo_changed)
                    combobox.pack_start(combo_widget, True, True, 0)
                    box.pack_start(combobox, False, True, 0)
                    self.widgets[option["name"]] = combo_widget
                elif option["type"] == "switch":
                    switchbox = Gtk.Box.new(Gtk.Orientation.HORIZONTAL, 10)
                    switchbox_label = Gtk.Label.new(option["label"])
                    switchbox_label.set_halign(Gtk.Align.START)
                    switchbox.pack_start(switchbox_label, True, True, 0)
                    switch_widget = Gtk.Switch.new()
                    switch_widget.set_active(option["value"])
                    switch_widget.set_halign(Gtk.Align.END)
                    switch_widget.set_valign(Gtk.Align.CENTER)
                    switch_widget.connect("state-set", self.on_switch_changed)
                    switchbox.pack_start(switch_widget, True, True, 0)
                    box.pack_start(switchbox, False, True, 0)
                    self.widgets[option["name"]] = switch_widget
        #---------------------------
        if len(self.widgets) > 0:
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
        self.setthemebox_label.set_line_wrap(True)
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
            self.adwaitabox_label.set_line_wrap(True)
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
        set_theme(self.current_theme_name, self.current_theme_name, reload_only = False)
        self.update_setthemebox()

    def on_combo_changed(self, combo):
        self.applybutton.set_sensitive(True)

    def on_switch_changed(self, switch, state):
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
        
        #Install theme
        try:
            print ("Running..." + " ".join(command))
            subprocess.run(command, check=True)
            print("Install finished OK")
        except subprocess.CalledProcessError as e:
            print(f"Install script error. Return code: {e.returncode}")
            print(f"Output:\n{e.output.decode('utf-8')}")
        
        #save settings
        self.save_config_file(new_theme_dir)

        #apply desktop theme
        set_theme(self.current_theme_name, new_theme_name, reload_only = True)
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

def gsettings_set(schema, key, old_value, new_value, reload_only):
    if not reload_only or gsettings_get(schema, key) == old_value:
        if Gio.SettingsSchemaSource.get_default().lookup(schema, True) is not None:
            print ("gsettings resetting " + schema + " " + key)
            setting = Gio.Settings.new(schema)
            if new_value == old_value:
                setting.set_string(key, "")
            setting.set_string(key, new_value)

def xfconf_get(channel, key):
    try:
        command = ["xfconf-query", "-c", channel, "-p", key]
        output = subprocess.check_output(command, text=True)
    except Exception as e:
        print("xfconf-query error: ", e)
        output = ""
    return output.rstrip("\n")

def xfconf_set(channel, key, theme_name, reload_only):
    if not reload_only or xfconf_get(channel, key) == theme_name:
        print ("xfconf-query resetting ", channel, key)
        subprocess.run(["xfconf-query", "-c", channel, "-p", key, "-r"])
        subprocess.run(["xfconf-query", "-c", channel, "-p", key, "-s", theme_name])

def is_current_theme(current_theme_name):
    if desktop_environment in {"GNOME", "pop", "Pantheon", "Budgie", "Unity"}:
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

def set_theme(current_theme_name, new_theme_name, reload_only):
    if desktop_environment in {"GNOME", "pop", "Pantheon"}:
        gsettings_set("org.gnome.desktop.interface", "gtk-theme",
                    current_theme_name, new_theme_name, reload_only)
    elif desktop_environment == "Cinnamon":
        gsettings_set("org.cinnamon.desktop.interface", "gtk-theme",
                            current_theme_name, new_theme_name, reload_only)
        gsettings_set("org.cinnamon.theme", "name", current_theme_name,
                                            new_theme_name, reload_only)
    elif desktop_environment == "XFCE":
        xfconf_set("xsettings", "/Net/ThemeName", current_theme_name, reload_only)
        #xfconf_set("xfwm4", "/general/theme", current_theme_name, reload_only)
    elif desktop_environment == "MATE":
        gsettings_set("org.mate.interface", "gtk-theme",
                            current_theme_name, new_theme_name, reload_only)
    elif desktop_environment == "Budgie":
        setting = Gio.Settings.new("org.gnome.desktop.interface")
        current_color_scheme = setting.get_string("color-scheme")
        gsettings_set("org.gnome.desktop.interface", "gtk-theme",
                            current_theme_name, new_theme_name, reload_only)
        time.sleep(1)
        setting.set_string("color-scheme", current_color_scheme)
    elif desktop_environment == "Unity":
        gsettings_set("org.gnome.desktop.interface", "gtk-theme",
                            current_theme_name, new_theme_name, reload_only)
        gsettings_set("org.gnome.desktop.wm.preferences", "theme",
                            current_theme_name, new_theme_name, reload_only)
    
if __name__ == "__main__":
    Gtk.init()

    win = OptionsWindow(desktop_environment, rename_theme_on_update)
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()  