library OpioidCDSREC10OrderSelect version '2022.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include OpioidCDSCommon version '2022.1.0' called Common
include OpioidCDSCommonConfig version '2022.1.0' called Config
include OpioidCDSRoutines version '2022.1.0' called Routines
include OpioidCDSREC10Common version '2022.1.0' called Rec10Common

parameter ContextPrescriptions List<MedicationRequest>

context Patient

define "Is Perform Drug Screen Recommendation Applicable?":
  Rec10Common."Inclusion Criteria For UDS Recommendation"

define "Applicable Because of Unexpected Results":
  Rec10Common."Inclusion Criteria For Unexpected Results"

define "Detail":
  Rec10Common."Get HTML Details"