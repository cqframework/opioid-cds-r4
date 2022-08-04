#!/bin/bash
#DO NOT EDIT WITH WINDOWS
tooling_jar=tooling-1.4.1-SNAPSHOT-jar-with-dependencies.jar
input_cache_path=$PWD/input-cache
patient_data_bundles=$PWD/input/examples
service_requests=$PWD/input/pagecontent/requests

tooling=$input_cache_path/$tooling_jar
if test -f "$tooling"; then
    JAVA -jar $tooling -RollTestsDataDates -v=r4 -ip="$patient_data_bundles"
    JAVA -jar $tooling -RollTestsDataDates -v=r4 -ip="$service_requests"
else
    tooling=../$tooling_jar
	echo $tooling
	if test -f "$tooling"; then
        JAVA -jar $tooling -RollTestsDataDates -v=r4 -ip="$patient_data_bundles"
        JAVA -jar $tooling -RollTestsDataDates -v=r4 -ip="$service_requests"
    else
        echo IG Refresh NOT FOUND in input-cache or parent folder.  Please run _updateCQFTooling.  Aborting...
	fi
fi