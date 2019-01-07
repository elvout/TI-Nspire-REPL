#! /usr/bin/env bash

sed -E -i '' "s/Compiled 20[0-9]{2}-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9] [AP]M/Compiled $(date '+%F %r')/" $1.lua

cat $1.lua > $1COMPILE.lua

for f in *.lua; do
	if [[ "$f" != $1*.lua ]]; then
		cat $f >> $1COMPILE.lua
	fi		
done

luna $1COMPILE.lua $1.tns

rm $1COMPILE.lua
