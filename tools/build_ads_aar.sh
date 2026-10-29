#!/usr/bin/env bash
# Compile android/ads-plugin into addons/riftrush_ads/bin/RiftRushAds.aar.
# Download caches stay in /tmp. Does not publish anything.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CACHE="${TMPDIR:-/tmp}/riftrush-ads-build"
mkdir -p "$CACHE" "$ROOT/addons/riftrush_ads/bin"
cd "$CACHE"

fetch() {
  local url="$1" out="$2"
  if [[ ! -s "$out" ]]; then
    echo "get $out"
    curl -fsSL -o "$out" "$url"
  fi
}

fetch "https://repo1.maven.org/maven2/org/godotengine/godot/4.7.1.stable/godot-4.7.1.stable.aar" godot.aar
fetch "https://dl.google.com/dl/android/maven2/com/google/android/gms/play-services-ads-api/25.5.0/play-services-ads-api-25.5.0.aar" ads-api.aar
fetch "https://dl.google.com/dl/android/maven2/com/google/android/ump/user-messaging-platform/4.0.0/user-messaging-platform-4.0.0.aar" ump.aar
fetch "https://repo1.maven.org/maven2/org/robolectric/android-all/17-robolectric-15733970/android-all-17-robolectric-15733970.jar" android-all.jar
fetch "https://dl.google.com/dl/android/maven2/androidx/annotation/annotation/1.8.2/annotation-1.8.2.jar" annotation.jar

rm -rf jars out aar
mkdir -p jars out aar
unzip -qo godot.aar classes.jar -d jars
mv jars/classes.jar jars/godot.jar
unzip -qo ads-api.aar classes.jar -d jars
mv jars/classes.jar jars/ads-api.jar
unzip -qo ump.aar classes.jar -d jars
mv jars/classes.jar jars/ump.jar

CP="jars/godot.jar:jars/ads-api.jar:jars/ump.jar:android-all.jar:annotation.jar"
find "$ROOT/android/ads-plugin/src" -name '*.java' > sources.txt
javac --release 17 -encoding UTF-8 -cp "$CP" -d out @sources.txt
jar cf aar/classes.jar -C out .
cp "$ROOT/android/ads-plugin/AndroidManifest.xml" aar/AndroidManifest.xml
cp "$ROOT/android/ads-plugin/proguard.txt" aar/proguard.txt
rm -f "$ROOT/addons/riftrush_ads/bin/RiftRushAds.aar"
(cd aar && zip -qr "$ROOT/addons/riftrush_ads/bin/RiftRushAds.aar" AndroidManifest.xml classes.jar proguard.txt)
echo "wrote addons/riftrush_ads/bin/RiftRushAds.aar"
