#!/bin/bash

FOLDER="$1"
HASH_FOLDER="${FOLDER%/}.dedup/hash"
LINK_FOLDER="${FOLDER%/}.dedup/link"

find $FOLDER -type f -links 1 | while read file
do
  hash_value=$(md5sum "$file" | cut -d\  -f1)
  hash_file=${hash_value:0:1}/${hash_value:1:2}/${hash_value:3}
  hash_path="$HASH_FOLDER/$hash_file"
  relative_path="${file#$FOLDER}"
  relative_path="${relative_path#/}"
  link_name="$LINK_FOLDER/$relative_path"
  link_dir=$(dirname "$link_name")
  mkdir -p "$link_dir"
  ln -rfs "$hash_path" "$link_name" 
  if [ ! -f "$hash_path" ]
  then
    mkdir -p "${hash_path%/*}"
    ln "$file" "$hash_path"
  else
    ln -f "$hash_path" "$file"
  fi
done

find $HASH_FOLDER -type f -links 1 -delete
find $LINK_FOLDER -type l | while read link
do
  relative_path="${link#$LINK_FOLDER/}"
  file="$FOLDER/$relative_path"
  if [ ! -f "$file" ]
  then
    rm "$link"
  fi
done
find $HASH_FOLDER -type d -empty -delete
find $LINK_FOLDER -type d -empty -delete
