#!/bin/sh
set -e

# Codemagic Workflow Editor → Build → Pre-build script
# (or run this script from a YAML workflow before `flutter build ipa`)
#
# Flutter's iOS build runs `pod install` without `--repo-update`.
# image_cropper 8.1.0 requires TOCropViewController ~> 2.7.4, which
# fails if the CocoaPods specs cache is stale.

flutter pub get
cd ios
pod install --repo-update
cd ..
