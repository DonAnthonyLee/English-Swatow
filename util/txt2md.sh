#!/bin/sh

convert_txt_to_md() {
	grep "\xCC" $1 > /dev/null 2>&1
	if [ "x$?" != "x0" ]; then
		# convert file in "docx" style to UTF-8 encoding
		sed -i -e 's/ñ2/2ñ/g' $1
		sed -i -e 's/ñ3/3ñ/g' $1
		sed -i -e 's/ñ4/4ñ/g' $1
		sed -i -e 's/ñ5/5ñ/g' $1
		sed -i -e 's/ñ6/6ñ/g' $1
		sed -i -e 's/ñ8/8ñ/g' $1
		sed -i -e 's/ñ/ⁿ/g' $1
		sed -i -e 's/ü/ṳ/g' $1
		sed -i -e 's/2/\xCC\x82/g' $1
		sed -i -e 's/3/\xCC\x81/g' $1
		sed -i -e 's/4/\xCC\x80/g' $1
		sed -i -e 's/5/\xCC\x83/g' $1
		sed -i -e 's/6/\xCC\x84/g' $1
		sed -i -e 's/8/\xCC\x8D/g' $1

		sed -i -e 's/\x0D/\n/g' $1
	fi

	grep "^\* " $1 > /dev/null 2>&1
	if [ "x$?" != "x0" ]; then
		# insert "* " to each line
		sed -i -e 's/^/* /g' $1
	fi

	return 0
}


if [ "x$1" = "x" -o "x$2" = "x" ]; then
	echo "Usage: $0 source destination"
	exit 1
fi

if [ ! -e $1 ]; then
	printf "\e[31mError: The source file does not exist!\e[0m\n"
	exit 1
fi

if [ -e $2 ]; then
	printf "\e[32mWarning: The destination file exists.\e[0m\n"
	read -p "Do you want to overwrite it? (Y/N)" choice
	case "$choice" in
		y | Y) ;;
		*) exit 1;;
	esac
fi

/bin/cp -f $1 $2
if [ "x$?" != "x0" ]; then
	printf "\e[31mError: Unable to duplicate file!\e[0m\n"
	exit 1
fi

convert_txt_to_md $2
if [ "x$?" != "x0" ]; then
	printf "\e[31mError: Conversion failed!\e[0m\n"
	exit 1
fi

exit 0
