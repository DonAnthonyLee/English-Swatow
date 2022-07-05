#!/bin/bash

show_usage() {
	echo "Usage: $0 syllables_pattern [files_pattern]"
	echo "Examples:"
	printf "\e[33m\t$0 siang-lai5-kann2\e[0m\n"
	printf "\e[33m\t$0 \"kue3 tso3\" *.md\e[0m\n"
}

inform_invalid_patterns() {
	show_usage
	printf "\e[31mError: Invalid patterns!\e[0m\n"
	exit 1
}

convert_pattern() {
	if [ "x$1" = "x+" -o "x$1" = "x++" ]; then
		printf $1
		return 0
	fi

	SYLLABLES="$1"

	syllable_len=`echo "$1" | awk -F "" '{print NF}'`

	if [ "x${SYLLABLES#*[1-8]}" != "x" ]; then
		tone="0"
	else
		tone=`echo "$1" | cut -b $syllable_len`
		((syllable_len--))
	fi

	SYLLABLES=${SYLLABLES:0:$syllable_len}

	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/ur/ṳ/g'`
	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/w/ṳ/g'`
	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/nn/ⁿ/g'`

	SYLLABLES=`echo "$SYLLABLES" | sed -r 's/^ch([a,o,ṳ,u])/ts\1/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -r 's/^chh([a,o,ṳ,u])/tsh\1/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -r 's/^j([a,o,ṳ,u])/z\1/'`

	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/^tsi/chi/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/^tshi/chhi/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/^zi/ji/'`

	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/^tse/che/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/^tshe/chhe/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/^ze/je/'`

	if [ "x$tone" = "x0" -o "x$tone" = "x1" -o "x$tone" = "x4" ]; then
		printf "$SYLLABLES"
		return 0;
	fi

	# FIXME: ûan / uân ...
	# ADVICE: readjust all modifiable tone characters of "-ua-" or "-ue-" or "-ui-", see "utils/replace-tone-characters.sh"

	syllable_len=`echo "$SYLLABLES" | awk -F "" '{print NF}'`
	SYLLABLES_PREFIX=""
	for v in a e o ṳ u i m n; do
		echo "$SYLLABLES" | grep "$v" > /dev/null 2>&1
		[ "$?" != 0 ] && continue
		SYLLABLES_PREFIX="${SYLLABLES/${v}*/${v}}"
		break
	done

	if [ "x$SYLLABLES_PREFIX" = "x" ]; then
		printf "$SYLLABLES"
		return 0;
	fi

	prefix_len=`echo "$SYLLABLES_PREFIX" | awk -F "" '{print NF}'`
	((syllable_len-=${prefix_len}))
	SYLLABLE_SUFFIX=${SYLLABLES:${prefix_len}:${syllable_len}}

	TONE_STR=""
	case "$tone" in
		2) TONE_STR=`printf "\xCC\x81"`;;
		3) TONE_STR=`printf "\xCC\x80"`;;
		5) TONE_STR=`printf "\xCC\x82"`;;
		6) TONE_STR=`printf "\xCC\x83"`;;
		7) TONE_STR=`printf "\xCC\x84"`;;
		8) TONE_STR=`printf "\xCC\x8D"`;;
	esac

	printf "${SYLLABLES_PREFIX}${TONE_STR}${SYLLABLE_SUFFIX}"
	return 0
}


if [ "x$1" = "x" ]; then
	show_usage
	exit 1
fi

[ "x$1" != "x*" ] || inform_invalid_patterns

echo "$1" | grep "\- " > /dev/null 2>&1
[ "$?" != 0 ] || inform_invalid_patterns

echo "$1" | grep " \-" > /dev/null 2>&1
[ "$?" != 0 ] || inform_invalid_patterns

echo "$1" | grep "\*" > /dev/null 2>&1
[ "$?" != 0 ] || inform_invalid_patterns

echo "$1" | grep "\?" > /dev/null 2>&1
[ "$?" != 0 ] || inform_invalid_patterns


DEFAULT_FILES_PATTERN="*.md"
[ "x$2" = "x" ] || DEFAULT_FILES_PATTERN="$2"

PATTERN_ARRAY=`echo "$1" | tr " " "\n" | tr "-" "\n"`
PATTERNS_CONVERTED=""
len=0
k=0


for p in $PATTERN_ARRAY; do
	sep=""
	str_len=`echo "$p" | awk -F "" '{print NF}'`
	if [ $k -gt 0 ]; then
		sep=`echo "$1" | cut -b $len`
		[ "x$sep" = "x" ] || PATTERNS_CONVERTED="${PATTERNS_CONVERTED}$sep"

		# for DEBUG
		#echo "sep = \"$sep\""
	fi
	pcd=`convert_pattern "$p"`

	[ "x$pcd" = "x" ] || PATTERNS_CONVERTED="${PATTERNS_CONVERTED}$pcd"
	((len+=${str_len}+1))
	((k++))

	# for DEBUG
	#echo "k = $k, str_len = ${str_len}, len = $len, p = \"$p\""
done

echo "PATTERNS_CONVERTED    = \"${PATTERNS_CONVERTED}\""
echo "DEFAULT_FILES_PATTERN = \"${DEFAULT_FILES_PATTERN}\""
echo "----------------------------------------------------"
find ./ -name "${DEFAULT_FILES_PATTERN}" -exec grep --color "${PATTERNS_CONVERTED}" {} \;

exit 0

