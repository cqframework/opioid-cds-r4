library OpioidCDS_ChronicPain

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0'

context Patient

/*
Recommendation #1 does not currently check chronic pain
*/

/*
Recommendation #2 uses "Ambulatory opioid medication with expected supply duration >= 28 days"
*/

/*
Recommendation #3 does not currently check chronic pain
*/

/*
Recommendation #4 does not currently check chronic pain
*/

/*
Recommendation #5 does not currently check chronic pain
*/

/*
Recommendation #6 uses a definition for "acute" pain as "Ambulatory opioid medication with expected supply duration < 28 days"
*/

/*
Recommendation #7 uses
Active 7 of Past 10 Days with Encounter or Active 63 of Past 90 Days seems to be a Chronic Pain determination, need a subroutine with consistent handling for this across recommendations
// NOTE: Active 63 of Past 90 Days is not quite the same as Active 21 of 30 days for each of the past 3 months, need to correct this
*/

/*
Recommendation #8 does not currently check chronic pain
*/

/*
Recommendation #9 does not currently check chronic pain
*/

/*
Recommendation #10 uses "Ambulatory opioid medication prescribed on at least 80 of the last 90 days"
*/

/*
Recommendation #11 does not currently check chronic pain
*/

/*
Recommendation #12 does not currently check chronic pain
*/
