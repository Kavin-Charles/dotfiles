#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Dark mode for Qt applications
export QT_STYLE_OVERRIDE=Fusion
export QT_QPA_PLATFORMTHEME=gtk3

# Include Flatpak apps in desktop application menus/launchers
export XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share"
