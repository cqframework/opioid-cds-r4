#!/bin/bash
rm bundlegen/bundlegen-bundle.json
rm bundlegen/sourcefiles/*

cp input/resources/activitydefinition/activitydefinition-opioidcds-urine-screening-request.xml bundlegen/sourcefiles/
cp input/resources/plandefinition/plandefinition-OpioidCDSREC10PatientView.xml bundlegen/sourcefiles/
cp input/resources/plandefinition/plandefinition-OpioidCDSREC11PatientView.xml bundlegen/sourcefiles/
cp input/resources/library/FHIRHelpers.json bundlegen/sourcefiles/
cp input/resources/library/OMTKData2020.json bundlegen/sourcefiles/
cp input/resources/library/OMTKLogicMK2020.json bundlegen/sourcefiles/
cp input/resources/library/OpioidCDSCommon.json bundlegen/sourcefiles/
cp input/resources/Library/OpioidCDSCommonConfig.json bundlegen/sourcefiles/
cp input/resources/Library/OpioidCDSRoutines.json bundlegen/sourcefiles/
cp input/resources/Library/OpioidCDSREC10PatientView.json bundlegen/sourcefiles/
cp input/resources/Library/OpioidCDSREC11PatientView.json bundlegen/sourcefiles/

#cd /bundlegen
for entry in "bundlegen/sourcefiles"/*
do
  echo bundling "$entry"
done

# Bundle all resources from bundlegen/sourcefiles
sh bundlegen/_bundle.sh

rm input/pagecontent/quick-start-bundles/opioid-cds-content-bundle.json
cp bundlegen/bundlegen-bundle.json input/pagecontent/quick-start-bundles/opioid-cds-content-bundle.json
echo 'Copied generated bundle to input/pagecontent/quick-start-bundles/opioid-cds-content-bundle.json'

echo 'Cleaning up bundlegen/sourcefiles...'
rm bundlegen/bundlegen-bundle.json
rm bundlegen/sourcefiles/*

echo 'quick start content bundle refresh complete.'

# refreshing Terminology bundles
echo refreshing terminology bundle...

cp input/vocabulary/valueset/valueset-benzodiazepine-medications.json bundlegen/sourcefiles/valueset-benzodiazepine-medications.json
cp input/vocabulary/valueset/valueset-buprenorphine-and-methadone-medications.json bundlegen/sourcefiles/valueset-buprenorphine-and-methadone-medications.json
cp input/vocabulary/valueset/valueset-cdc-malignant-cancer-conditions.json bundlegen/sourcefiles/valueset-cdc-malignant-cancer-conditions.json
cp input/vocabulary/valueset/valueset-conditions-documenting-substance-misuse.json bundlegen/sourcefiles/valueset-conditions-documenting-substance-misuse.json
cp input/vocabulary/valueset/valueset-conditions-likely-terminal-for-opioid-prescribing.json bundlegen/sourcefiles/valueset-conditions-likely-terminal-for-opioid-prescribing.json
cp input/vocabulary/valueset/valueset-discharge-to-hospice.xml bundlegen/sourcefiles/valueset-discharge-to-hospice.xml
cp input/vocabulary/valueset/valueset-extended-release-opioid-with-ambulatory-misuse-potential.json bundlegen/sourcefiles/valueset-extended-release-opioid-with-ambulatory-misuse-potential.json
cp input/vocabulary/valueset/valueset-hospice-disposition.xml bundlegen/sourcefiles/valueset-hospice-disposition.xml
cp input/vocabulary/valueset/valueset-hospice-finding.xml bundlegen/sourcefiles/valueset-hospice-finding.xml
cp input/vocabulary/valueset/valueset-hospice-procedure.xml bundlegen/sourcefiles/valueset-hospice-procedure.xml
cp input/vocabulary/valueset/valueset-limited-life-expectancy-conditions.json bundlegen/sourcefiles/valueset-limited-life-expectancy-conditions.json
cp input/vocabulary/valueset/valueset-naloxone-medications.json bundlegen/sourcefiles/valueset-naloxone-medications.json
cp input/vocabulary/valueset/valueset-non-opioid-drug-urine-screening.json bundlegen/sourcefiles/valueset-non-opioid-drug-urine-screening.json
cp input/vocabulary/valueset/valueset-office-visit.json bundlegen/sourcefiles/valueset-office-visit.json
cp input/vocabulary/valueset/valueset-oncology-specialty-designations.json bundlegen/sourcefiles/valueset-oncology-specialty-designations.json
cp input/vocabulary/valueset/valueset-opioid-analgesics-with-ambulatory-misuse-potential.json bundlegen/sourcefiles/valueset-opioid-analgesics-with-ambulatory-misuse-potential.json
cp input/vocabulary/valueset/valueset-opioid-counseling-procedure.json bundlegen/sourcefiles/valueset-opioid-counseling-procedure.json
cp input/vocabulary/valueset/valueset-opioid-drug-urine-screening.json bundlegen/sourcefiles/valueset-opioid-drug-urine-screening.json
cp input/vocabulary/valueset/valueset-opioid-misuse-assessment-procedure.json bundlegen/sourcefiles/valueset-opioid-misuse-assessment-procedure.json
cp input/vocabulary/valueset/valueset-opioid-misuse-disorders.json bundlegen/sourcefiles/valueset-opioid-misuse-disorders.json
cp input/vocabulary/valueset/valueset-opioidcds-indicator.xml bundlegen/sourcefiles/valueset-opioidcds-indicator.xml
cp input/vocabulary/valueset/valueset-pain-management-procedure.json bundlegen/sourcefiles/valueset-pain-management-procedure.json
cp input/vocabulary/valueset/valueset-pain-treatment-plan.json bundlegen/sourcefiles/valueset-pain-treatment-plan.json
cp input/vocabulary/valueset/valueset-pdmp-data-reviewed-finding.json bundlegen/sourcefiles/valueset-pdmp-data-reviewed-finding.json
cp input/vocabulary/valueset/valueset-pdmp-review-procedure.json bundlegen/sourcefiles/valueset-pdmp-review-procedure.json
cp input/vocabulary/valueset/valueset-substance-misuse-behavioral-counseling.json bundlegen/sourcefiles/valueset-substance-misuse-behavioral-counseling.json
cp input/vocabulary/valueset/valueset-therapies-indicating-end-of-life-care.json bundlegen/sourcefiles/valueset-therapies-indicating-end-of-life-care.json

#cd /bundlegen
for entry in "bundlegen/sourcefiles"/*
do
  echo bundling "$entry"
done

# Bundle all resources from bundlegen/sourcefiles
sh bundlegen/_bundle.sh

rm input/pagecontent/quick-start-bundles/opioid-cds-terminology-bundle.json
cp bundlegen/bundlegen-bundle.json input/pagecontent/quick-start-bundles/opioid-cds-terminology-bundle.json
echo 'Copied generated bundle to input/pagecontent/quick-start-bundles/opioid-cds-terminology-bundle.json'

echo 'Cleaning up bundlegen/sourcefiles...'
rm bundlegen/bundlegen-bundle.json
rm bundlegen/sourcefiles/*

echo 'quick start terminology bundle refresh complete.'
