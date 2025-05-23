#!/bin/bash
#
# Written by Anthony Lee <don.anthony.lee@gmail.com>
#

show_usage() {
	echo "Usage: $0 syllables_pattern [args for grep]"
	echo "Examples:"
	printf "\e[33m\t$0 tseng3-nang5\e[0m\n"
	printf "\e[33m\t$0 \"tshiu2 sng\" A.md\e[0m\n"
	printf "\e[33m\tfind ./ -name \"*.md\" -exec $0 \"lw2 kai5\" {} \;\e[0m\n"
}

inform_invalid_patterns() {
	show_usage
	printf "\e[31mError: Invalid patterns!\e[0m\n"
	exit 1
}

convert_pattern() {
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
	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/nn$/ⁿ/'`

	SYLLABLES=`echo "$SYLLABLES" | sed -r 's/^ch([a,o,ṳ,u])/ts\1/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -r 's/^chh([a,o,ṳ,u])/tsh\1/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -r 's/^j([a,o,ṳ,u])/z\1/'`

	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/^tsi/chi/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/^tshi/chhi/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/^zi/ji/'`

	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/^tse/che/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/^tshe/chhe/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/^ze/je/'`

	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/oa/ua/'`
	SYLLABLES=`echo "$SYLLABLES" | sed -e 's/oe/ue/'`

	syllable_len=`echo "$SYLLABLES" | awk -F "" '{print NF}'`
	SYLLABLES_PREFIX=""
	VOWEL=""
	for v in a e o ṳ u i m n; do
		echo "$SYLLABLES" | grep "$v" > /dev/null 2>&1
		[ "$?" != 0 ] && continue
		SYLLABLES_PREFIX="${SYLLABLES/${v}*/${v}}"
		VOWEL="$v"
		break
	done

	if [ -z "$VOWEL" ]; then
		for v in A E O Ṳ U I M N; do
			echo "$SYLLABLES" | grep "$v" > /dev/null 2>&1
			[ "$?" != 0 ] && continue
			SYLLABLES_PREFIX="${SYLLABLES/${v}*/${v}}"
			VOWEL="$v"
			break
		done
	fi

	if [ "x$SYLLABLES_PREFIX" = "x" ]; then
		printf "$SYLLABLES"
		return 0;
	fi

	prefix_len=`echo "$SYLLABLES_PREFIX" | awk -F "" '{print NF}'`
	((syllable_len-=${prefix_len}))
	bash --version | grep "bash, version 4." > /dev/null 2>&1
	if [ $? == 0 ]; then # bash 4.x
		if [ "x$VOWEL" = "xṳ" -o "x$VOWEL" = "xṲ" ]; then
			((prefix_len--))
		fi
	fi
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

	if [ $prefix_len -gt 1 ]; then
		pos=$prefix_len;
		((pos-=2))
		CHAR_PRE=${SYLLABLES:${pos}:1}
		if [ "x${CHAR_PRE}" = "xo" -o "x${CHAR_PRE}" = "xO" ]; then # oa; oe; oi; &etc.
			SYLLABLES_PREFIX=${SYLLABLES:0:${pos}}
			printf "${SYLLABLES_PREFIX}${CHAR_PRE}${TONE_STR}${VOWEL}${SYLLABLE_SUFFIX}"
			return 0
		elif [ "x${CHAR_PRE}" = "xu" -o "x${CHAR_PRE}" = "xU" ]; then # ua; ue
			if [ "x$VOWEL" = "xa" -o "x$VOWEL" = "xA" ]; then
				SYLLABLES_PREFIX=${SYLLABLES:0:${pos}}
				SYLLABLES_PREFIX="${SYLLABLES_PREFIX}(${CHAR_PRE}${TONE_STR}${VOWEL}"
				if [ "x$CHAR_PRE" = "xu" ]; then
					SYLLABLES_PREFIX="${SYLLABLES_PREFIX}|o${TONE_STR}${VOWEL}"
				else
					SYLLABLES_PREFIX="${SYLLABLES_PREFIX}|O${TONE_STR}${VOWEL}"
				fi
				SYLLABLES_PREFIX="${SYLLABLES_PREFIX}|${CHAR_PRE}${VOWEL}${TONE_STR})"
				printf "${SYLLABLES_PREFIX}${SYLLABLE_SUFFIX}"
				return 0
			elif [ "x$VOWEL" = "xE" -o "x$VOWEL" = "xe" ]; then
				SYLLABLES_PREFIX=${SYLLABLES:0:${pos}}
				SYLLABLES_PREFIX="${SYLLABLES_PREFIX}(${CHAR_PRE}${TONE_STR}${VOWEL}"
				SYLLABLES_PREFIX="${SYLLABLES_PREFIX}|${CHAR_PRE}${VOWEL}${TONE_STR})"
				printf "${SYLLABLES_PREFIX}${SYLLABLE_SUFFIX}"
				return 0
			fi
		fi
	fi

	if [ $syllable_len -gt 0 ]; then
		if [ "x$VOWEL" = "xa" -o "x$VOWEL" = "xA" ]; then
			CHAR_NEXT=${SYLLABLE_SUFFIX:0:1}
			if [ "x${CHAR_NEXT}" = "xu" -o "x${CHAR_NEXT}" = "xU" ]; then # au
				pos=$prefix_len;
				((pos-=1))
				SYLLABLES_PREFIX=${SYLLABLES:0:${pos}}
				SYLLABLES_PREFIX="${SYLLABLES_PREFIX}(${VOWEL}${TONE_STR}${CHAR_NEXT}"
				SYLLABLES_PREFIX="${SYLLABLES_PREFIX}|${VOWEL}${CHAR_NEXT}${TONE_STR})"
				((syllable_len-=1))
				((prefix_len+=1))
				if [ $syllable_len -gt 0 ]; then
					printf "${SYLLABLES_PREFIX}${SYLLABLES:${prefix_len}:${syllable_len}}"
				else
					printf "${SYLLABLES_PREFIX}"
				fi
				return 0
			fi
		fi
	fi

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


GREP_ARGS="*.md"
[ "x$2" = "x" ] || GREP_ARGS="$2"

# TODO: -,*,? &etc.
PATTERN_ARRAY=`echo "$1" | tr " " "\n" | tr "-" "\n" | sed -e 's/^\s*$/-/g'`
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
	if [ "x$p" != "x-" ]; then
		pcd=`convert_pattern "$p"`
		[ "x$pcd" = "x" ] || PATTERNS_CONVERTED="${PATTERNS_CONVERTED}$pcd"
		((len+=${str_len}+1))
	else
		if [ $k -eq 0 ]; then
			PATTERNS_CONVERTED="\\"
		fi
		((len++))
	fi
	((k++))

	# for DEBUG
	#echo "k = $k, str_len = ${str_len}, len = $len, p = \"$p\""
done

echo "PATTERNS_CONVERTED = \"${PATTERNS_CONVERTED}\""
echo "GREP_ARGS = \"${GREP_ARGS}\""
echo "----------------------------------------------------"
grep --color -E "${PATTERNS_CONVERTED}" ${GREP_ARGS}

exit 0

