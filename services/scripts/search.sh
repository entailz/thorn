#!/bin/bash

goog="https://www.google.com/search?q={}"
web="https://{}"

INPUT=$1

echo "Input: $INPUT"

is_url() {
	[[ "$1" =~ ^(http://|https://|www\.|ftp://) ]] || [[ "$1" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]
}

if [[ -z "$INPUT" ]]; then
	echo "No input provided. Exiting."
	exit 1
fi

if is_url "$INPUT"; then
	if [[ ! "$INPUT" =~ ^http:// && ! "$INPUT" =~ ^https:// && ! "$INPUT" =~ ^www\. && ! "$INPUT" =~ ^ftp:// ]]; then
		URL="https://$INPUT"
	else
		URL="$INPUT"
	fi
	echo "Opening URL: $URL"
	xdg-open "$URL"
else
	echo "Performing Google search for: $INPUT"
	xdg-open "$(echo "$goog" | sed "s/{}/$INPUT/")"
fi
