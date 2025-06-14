#!/usr/bin/env bash

# Check if a directory argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory> <refresh|remove> [image_path]"
  exit 1
fi

DIRECTORY="$1"
OUTPUT_JSON="$DIRECTORY/output.json"
DELETED_DIR="$DIRECTORY/deleted"

if [ "$2" == "refresh" ]; then
  # Start the JSON structure
  echo "{" >"$OUTPUT_JSON"
  echo '   "images": {' >>"$OUTPUT_JSON"

  # Loop through all files in the specified directory
  for file in "$DIRECTORY"/*; do
    # Check if it's a file and has a valid image extension
    if [ -f "$file" ] && [[ "$file" =~ \.(jpg|jpeg|png|gif|bmp|tiff|webp)$ ]]; then
      name=$(basename "$file")
      name_no_ext=$(echo "$name" | sed 's/\.[^.]*$//')
      path=$(realpath "$file")

      echo '        "'"$name_no_ext"'": {' >>"$OUTPUT_JSON"
      echo '            "path": "'"$path"'"' >>"$OUTPUT_JSON"
      echo '        },' >>"$OUTPUT_JSON"
    fi
  done

  # Remove the trailing comma from the last JSON object, if any
  sed -i '$s/,$//' "$OUTPUT_JSON"

  # Close the JSON structure
  echo '   }' >>"$OUTPUT_JSON"
  echo "}" >>"$OUTPUT_JSON"

  echo "JSON file created: $OUTPUT_JSON"
elif [ "$2" == "remove" ]; then
  # Check if the path argument is provided
  if [ -z "$3" ]; then
    echo "Usage: $0 <directory> remove <image_path>"
    exit 2
  fi

  IMAGE_PATH="$DIRECTORY/$3"

  # Remove the entry with the specified path
  if [ -f "$OUTPUT_JSON" ]; then
    if [ ! -d "$DELETED_DIR" ]; then
      mkdir "$DELETED_DIR"
    fi

    tmp_file=$(mktemp)

    # Use jq to filter out the entry based on the path
    jq --arg path "$IMAGE_PATH" '{
            images: .images | to_entries | map(select(.value.path != $path)) | from_entries
        }' "$OUTPUT_JSON" >"$tmp_file" && mv "$tmp_file" "$OUTPUT_JSON"

    # Move the file to the deleted folder
    if [ -f "$IMAGE_PATH" ]; then
      mv "$IMAGE_PATH" "$DELETED_DIR"
      echo "File '$IMAGE_PATH' moved to '$DELETED_DIR/'."
    else
      echo "File '$IMAGE_PATH' not found. Entry removed from JSON only."
    fi

    echo "Entry with path '$IMAGE_PATH' removed from $OUTPUT_JSON."
  else
    echo "JSON file '$OUTPUT_JSON' not found."
  fi
else
  echo "Usage: $0 <directory> <refresh|remove>"
  exit 1
fi
