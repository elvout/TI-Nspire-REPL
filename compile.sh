#! /usr/bin/env bash

sed -E -i '' "s/Compiled 20[0-9]{2}-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9] [AP]M/Compiled $(date '+%F %r')/" term.lua

cat term.lua > termCOMPILE.lua

for f in *.lua; do
	if [[ "$f" != term*.lua ]] && [[ "$f" != test.lua ]]; then
		cat $f >> termCOMPILE.lua
	fi		
done

luna termCOMPILE.lua term.tns

rm termCOMPILE.lua
