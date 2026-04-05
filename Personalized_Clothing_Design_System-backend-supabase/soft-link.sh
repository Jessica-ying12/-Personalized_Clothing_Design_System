#!/bin/sh
cd docs/skills/
for file in *; do
    ln -s "$(pwd)/$file" ../../.trae/skills/"$file"
done
cd -
