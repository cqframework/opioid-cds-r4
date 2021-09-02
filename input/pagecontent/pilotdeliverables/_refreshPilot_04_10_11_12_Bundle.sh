#!/bin/bash
rm bundlegen/bundlegen-bundle.json
rm bundlegen/sourcefiles/*

cp input/resources/plandefinition/plandefinition-OpioidCDSREC04PatientView.xml bundlegen/sourcefiles/
cp input/resources/plandefinition/plandefinition-OpioidCDSREC10PatientView.xml bundlegen/sourcefiles/
cp input/resources/plandefinition/plandefinition-OpioidCDSREC11PatientView.xml bundlegen/sourcefiles/
cp input/resources/plandefinition/plandefinition-OpioidCDSREC12PatientView.xml bundlegen/sourcefiles/
cp input/resources/library/FHIRHelpers.json bundlegen/sourcefiles/
cp input/resources/library/OMTKData2020.json bundlegen/sourcefiles/
cp input/resources/library/OMTKLogicMK2020.json bundlegen/sourcefiles/
cp input/resources/library/OpioidCDSCommon.json bundlegen/sourcefiles/
cp input/resources/library/OpioidCDSCommonConfig.json bundlegen/sourcefiles/
cp input/resources/library/OpioidCDSRoutines.json bundlegen/sourcefiles/
cp input/resources/library/OpioidCDSREC04PatientView.json bundlegen/sourcefiles/
cp input/resources/library/OpioidCDSREC10PatientView.json bundlegen/sourcefiles/
cp input/resources/library/OpioidCDSREC11PatientView.json bundlegen/sourcefiles/
cp input/resources/library/OpioidCDSREC12PatientView.json bundlegen/sourcefiles/

#cd /bundlegen
for entry in "bundlegen/sourcefiles"/*
do
  echo bundling "$entry"
done

# Bundle all resources from bundlegen/sourcefiles
sh bundlegen/_bundle.sh

rm input/pagecontent/pilotdeliverables/recs-04pv-10pv-11pv-12-content-bundle.json
cp bundlegen/bundlegen-bundle.json input/pagecontent/pilotdeliverables/recs-04pv-10pv-11pv-12-content-bundle.json
echo 'Copied generated bundle to input/pagecontent/pilotdeliverables/recs-04pv-10pv-11pv-12-content-bundle.json'

echo 'Cleaning up bundlegen/sourcefiles...'
rm bundlegen/bundlegen-bundle.json
rm bundlegen/sourcefiles/*

echo 'recs-04pv-10pv-11pv-12-content-bundle content bundle refresh complete.'
