@ECHO OFF
SET tooling_jar=tooling-cli-3.8.0.jar
SET input_cache_path=%~dp0/input-cache
SET patient_data_bundles=%~dp0/input/examples
SET service_requests=%~dp0/input/pagecontent/requests

SET JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8

IF EXIST "%input_cache_path%\%tooling_jar%" (
	JAVA -jar "%input_cache_path%\%tooling_jar%" -RollTestsDataDates -v=r4 -ip="%patient_data_bundles%"
    JAVA -jar "%input_cache_path%\%tooling_jar%" -RollTestsDataDates -v=r4 -ip="%service_requests%"
) ELSE If exist "..\%tooling_jar%" (
	JAVA -jar "..\%tooling_jar%" -RollTestsDataDates -v=r4 -ip="%patient_data_bundles%"
    JAVA -jar "..\%tooling_jar%" -RollTestsDataDates -v=r4 -ip="%service_requests%"
) ELSE (
	ECHO IG Refresh NOT FOUND in input-cache or parent folder.  Please run _updateCQFTooling.  Aborting...
)

PAUSE