#!/bin/bash

version="0.0"

if [[ -n $1 ]]; then
	num_lines=$1
else
	echo
	echo "charfudge - Generate characters with multiple iterations of random encoding"
	echo
	echo "	version $version © 2024, Bálint Magyar"
	echo "	https://github.com/balintmagyar/charfudge"
	echo
	echo "	Usage: charfudge <number of lines to generate>"
	exit 1
fi

num_chars_per_line=1

codes=()							# populate codes
for i in {0..255}; do
	codes+=("$(printf   "%02X" "$i")")			#   00..  FF
	codes+=("$(printf "10%02X" "$i")")			# 1000..10FF
	codes+=("$(printf "20%02X" "$i")")			# 2000..20FF
	codes+=("$(printf "30%02X" "$i")")			# 3000..30FF
	codes+=("$(printf "FF%02X" "$i")")			# FF00..FFFF
done
								# emoji
codes+=('1F326' '1F480' '1F4A9' '1F921' '1F916' '1F640' '1F648' '1F4A5' '1F440' '1FAE6' '1FAC2' '1F40D' '1F41E')

# transform functions and encodings are picked randomly for each character from these pools
transforms=('raw' 'code_escape' 'force_32bit_unicode_escape' 'force_32bit_unicode_escape_braces')
encodings=('url' 'shell' 'js')

# helper functions
function zeropad {
	target_length=$2
	printf "%0${target_length}s" "$1" | tr ' ' '0'
}

# encoding functions
function encode_url {
	chars="$(printf "%s" "$1")"
	output=""

	for (( i=0; i < ${#chars}; i++ )); do
		char="$(printf "%s" "${chars:i:1}")"

		if [[ "$char" =~ [a-zA-Z0-9] ]]; then
			output+="$char"
		else
			hex_sequence="$(echo -n "$char" | xxd -p)"
			output+="$(echo "$hex_sequence" | sed 's/\(..\)/%\1/g' | tr [:lower:] [:upper:])"
		fi
	done

	echo "$output"
}

function encode_shell {
	printf "%q" "$1"
}

function encode_js {
	echo -n "$1" | sed 's/\\/\\\\/g; s/'"'"'/\\'"'"'/g; s/"/\\"/g; s/\n/\\n/g; s/\r/\\r/g; s/\t/\\t/g; s/\\b/\\\\b/g; s/\f/\\f/g'
}

# transform functions
function transform_code_escape {
	code="$1"
	output=""

	length=${#code}
	target_length=${#code}
	if [[ $2 -gt $length ]]; then target_length=$2; fi
	if [[ $target_length -gt $length ]]; then return; fi

	if	[[ $target_length -gt 4 ]]; then		output+="\\U$(zeropad "$code" 8)";
	elif	[[ $target_length -gt 2 ]]; then		output+="\\u$(zeropad "$code" 4)";
	elif	[[ $target_length  == 2 ]]; then		output+="\\x$code";		fi

	echo -n "$output"
}

function transform_raw {			 		echo -ne "$(transform_code_escape "$1")";	}
function transform_force_32bit_unicode_escape {			printf "\\\\u%s" "$(zeropad "$1" 8)";		}
function transform_force_32bit_unicode_escape_braces {		printf "\\\\u{%s}" "$(zeropad "$1" 8)";		}

# generate output
final_output=""

for (( k=0; k < $num_lines; k++ )); do
	for (( i=0; i < $num_chars_per_line; i++ )); do
		current_encoded_char=""
		random_code_index=0
		random_transform_index=0
		random_num_encodings=0

		# pick random code point
		random_code_index=$(shuf -n 1 -i 0-${#codes[@]})
		random_code="${codes[$random_code_index]}"

		# pick random transform
		random_transform_index=$(shuf -n 1 -i 0-$(( ${#transforms[@]} - 1)))
		random_transform_name="${transforms[$random_transform_index]}"

		# pick and apply random encodings
		current_encoded_char="$(eval "transform_$random_transform_name $random_code")"
		random_num_encodings=$(shuf -n 1 -i 0-${#encodings[@]})

		for (( j=0; j < $random_num_encodings; j++ )); do
			random_encoding_index=$(shuf -n 1 -i 0-2)
			random_encoding_name="${encodings[$random_encoding_index]}"

			current_encoded_char="$(eval "encode_$random_encoding_name \"\$current_encoded_char\"")"
		done

		final_output+="$current_encoded_char"$'\n'
	done
done

# output
echo -n "$final_output"
