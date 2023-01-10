#!/bin/bash

version=$1
gsed -i "s|^\(version:\).*$|\1 $version|gm" pubspec.yaml

git add .
git commit -m "Update to $1"
git tag $1
git push && git push --tags
dart pub publish