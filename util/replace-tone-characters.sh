#!/bin/bash

if [ "x$1" = "x" ]; then
	echo "Usage: $0 file"
	exit 1
fi


# readjust all modifiable tone characters of "-ua-" or "-ue-" or "-ui-"
for v in i a e; do
	for tone in 2 3 5 6 7 8; do
		TONE_STR=""
		case "$tone" in
			2) TONE_STR=`printf "\xCC\x81"`;;
			3) TONE_STR=`printf "\xCC\x80"`;;
			5) TONE_STR=`printf "\xCC\x82"`;;
			6) TONE_STR=`printf "\xCC\x83"`;;
			7) TONE_STR=`printf "\xCC\x84"`;;
			8) TONE_STR=`printf "\xCC\x8D"`;;
		esac

		if [ "$v" = "i" ]; then
			SRC_STR="u${v}${TONE_STR}"
			DEST_STR="u${TONE_STR}${v}"
		else
			SRC_STR="u${TONE_STR}${v}"
			DEST_STR="u${v}${TONE_STR}"
		fi

		sed -i -e "s/${SRC_STR}/${DEST_STR}/g" $1
	done
done

exit 0