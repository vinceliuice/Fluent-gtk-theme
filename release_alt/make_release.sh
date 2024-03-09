#! /bin/bash

echo Copying source files...

cp -R ./source ./Fluent
cp -R ../src ./Fluent/config/

rm ./Fluent/config/src/cinnamon/*.css
rm ./Fluent/config/src/cinnamon/thumbnail.svg
rm ./Fluent/config/src/gnome-shell/shell-3-28/*.css
rm ./Fluent/config/src/gnome-shell/shell-40-0/*.css
rm ./Fluent/config/src/gnome-shell/shell-42-0/*.css
rm ./Fluent/config/src/gnome-shell/shell-44-0/*.css
rm ./Fluent/config/src/gtk/3.0/*.css
rm ./Fluent/config/src/gtk/4.0/*.css

rm ./Fluent/config/src/gtk/assets*svg
rm ./Fluent/config/src/gtk/{assets.txt,make-assets.sh,render-assets.sh}

rm ./Fluent/config/src/gtk-2.0/assets-folder/assets*svg
rm ./Fluent/config/src/gtk-2.0/assets-folder/{assets.txt,render-assets.sh}

rm ./Fluent/config/src/xfwm4/assets*svg
rm ./Fluent/config/src/xfwm4/{assets.txt,render-assets.sh}

echo Done.
echo Creating tar.xz file...

rm ./Fluent.tar.xz

tar -Jcf Fluent.tar.xz Fluent

rm -r ./Fluent

echo Done.