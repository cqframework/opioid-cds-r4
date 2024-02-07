#!/bin/bash
#DO NOT EDIT WITH WINDOWS
# tooling_jar=tooling-1.4.1-SNAPSHOT-jar-with-dependencies.jar
tooling_jar=tooling-cli-2.1.0-SNAPSHOT.jar
input_cache_path=$PWD/input-cache
resources_path=/input/resources
ig_ini_path=$PWD/ig.ini

set -e
echo Checking internet connection...
wget -q --spider tx.fhir.org

if [ $? -eq 0 ]; then
	echo "Online"
	fsoption=""
#"-fs http://cqm-sandbox.alphora.com/cqf-ruler-r4/fhir/"
else
	echo "Offline"
	fsoption=""
fi

echo "$fsoption"

tooling=$input_cache_path/$tooling_jar
if test -f "$tooling"; then
	JAVA -jar $tooling -RefreshIG -ini="$ig_ini_path" -rp="$resources_path" -d -p -t -ss=false $fsoption
	chmod +x ./_refreshTestData.sh
else
	tooling=../$tooling_jar
	echo $tooling
	if test -f "$tooling"; then
		JAVA -jar $tooling -RefreshIG -ini="$ig_ini_path" -rp="$resources_path" -d -p -t -ss=false $fsoption
		chmod +x ./_refreshTestData.sh
	else
		echo IG Refresh NOT FOUND in input-cache or parent folder.  Please run _updateCQFTooling.  Aborting...
	fi
fi
