#!/usr/bin/env bash
# Make XFCE look like macOS: top menu bar, Plank dock, WhiteSur theme, left window buttons.
sleep 6
x() { xfconf-query -c "$1" -p "$2" --create -t "$3" -s "$4" 2>/dev/null; }
x xsettings /Net/ThemeName string WhiteSur-Dark
x xsettings /Net/IconThemeName string WhiteSur-dark
x xsettings /Gtk/FontName string "Inter 11"
x xfwm4 /general/theme string WhiteSur-Dark
x xfwm4 /general/button_layout string "CHM|O"
x xfwm4 /general/use_compositing bool true
x xfwm4 /general/title_font string "Inter Semi-Bold 10"
for m in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E 'last-image$'); do
  xfconf-query -c xfce4-desktop -p "$m" -s /usr/share/backgrounds/skull/skull.svg
done
x xfce4-desktop /backdrop/screen0/monitorVNC-0/workspace0/last-image string /usr/share/backgrounds/skull/skull.svg
# single top panel = menu bar; drop the bottom panel in favour of Plank
x xfce4-panel /panels/panel-1/position string "p=6;x=0;y=0"
x xfce4-panel /panels/panel-1/size uint 28
xfconf-query -c xfce4-panel -p /panels -t int -s 1 --force-array 2>/dev/null && xfce4-panel -r &
mkdir -p ~/.config/plank/dock1/launchers
for app in thunar skull-browser skull-claude xfce4-terminal skull-sync-setup; do
  f=/usr/share/applications/$app.desktop
  [ -f "$f" ] && printf '[PlankDockItemPreferences]\nLauncher=file://%s\n' "$f" > ~/.config/plank/dock1/launchers/$app.dockitem
done
pkill -x plank; (sleep 1; plank) &
