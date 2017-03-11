#!/bin/sh
#151125 ander
#170118 sfs
#VERSION 3.0
if [ ! -d "$1" ] ; then
    echo "Update caches when module load/unload"
    echo "Run by pfs utils, not user"
    echo "Usage: $0 <mount point loaded/half-unloaded module>"
    exit
fi

[ "$(find "$1"{,/usr{,/local,/X11R6}}/lib -type f -name "*.so" 2>/dev/null)" ] && ldconfig &
[ -d "$1/usr/share/mime/" ] && update-mime-database /usr/share/mime &
[ -d "$1/usr/lib/gdk-pixbuf-2.0/" ]  && gdk-pixbuf-query-loaders --update-cache &
[ -d "$1/usr/share/icons/hicolor/" ] && gtk-update-icon-cache -f -i -q /usr/share/icons/hicolor &
[ -d "$1/usr/share/applications/" -o -d "$1/usr/local/share/applications/" ] && update-desktop-database -q &
[ -d "$1/usr/share/glib-2.0/schemas/" ]  && glib-compile-schemas /usr/share/glib-2.0/schemas/ &
for script in $(ls $(dirname $0)/fixmenus*) ; do $script "$1" &; done 
for font_dir in /usr/share/fonts{,/default}/TTF  /usr/X11R6/lib/X11/fonts/TTF ; do
    if [ -d "$1/${font_dir}" ]; then
	fcneed=on
	mkfontscale ${font_dir} & 
	mkfontdir ${font_dir} &
    fi
done
[ $fcneed ] && fc-cache -f -s &