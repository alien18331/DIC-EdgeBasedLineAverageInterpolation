#!/bin/sh

name="ELA"

echo "run $name project ..."

if [ -d ".tmp/Documentary_category" ]; then
    rm -r .tmp/Documentary_category
    echo "remove .tmp/Documentary_category/"
fi
if [ -d ".tmp/RTL_category" ]; then
    rm -r .tmp/RTL_category
    echo "remove .tmp/RTL_category"
fi
if [ -d ".tmp/Gate-Level_category" ]; then
    rm -r .tmp/Gate-Level_category
    echo "remove .tmp/Gate-Level_category/"
fi
if [ -f "syn/$name.vo" ]; then
    rm syn/$name.vo
    echo "remove syn/$name.vo"
fi
if [ -f "syn/${name}_v.sdo" ]; then
    rm syn/${name}_v.sdo
    echo "remove syn/${name}_v.sdo"
fi
if [ -f "src/$name.v" ]; then
    rm src/$name.v
    echo "remove src/$name.v"
fi
unzip doc/HW4_P76061386_沈育同_v*.zip -d .tmp/
cp .tmp/RTL_category/$name.v src/$name.v
echo "copy $name.v"
cp .tmp/Gate-Level_category/${name}_v.sdo syn/${name}_v.sdo
echo "copy ${name}_v.sdo"
cp .tmp/Gate-Level_category/$name.vo syn/$name.vo
echo "copy $name.vo"
echo "successfully"
