#!/bin/sh

print_syntax() { echo "$0" X.Y.Z ; exit "${1:-1}"; }

if [ -z "$1" ]; then
	print_syntax
fi

if [ "$1" = "$(echo "$1" | sed -E 's/[0-9]+(\.[0-9]+)+//')" ]; then
	echo invalid verion number $1
	print_syntax
	exit
fi

version="$1"
tag_date="$(date +%Y-%m-%d)"
echo applying new version "$version" with date "$tag_date"

sed -i '' "s/^_POT_VERSION=.*$/_POT_VERSION=$version/" 'bin/pot'
sed -i '' 's/^## \[Unreleased\]/## \[Unreleased\]\
\
### NEWVERSION/' CHANGELOG.md

sed -i '' "s/### NEWVERSION/## \[$version\] $tag_date/" CHANGELOG.md

sed -i '' "s/^version = .*$/version = \"$version\"/" 'share/doc/pot/conf.py'
sed -i '' "s/^release = .*$/release = \"$version\"/" 'share/doc/pot/conf.py'

git diff -p --stat
