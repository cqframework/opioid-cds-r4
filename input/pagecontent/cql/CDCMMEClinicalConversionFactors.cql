library CDCMMEClinicalConversionFactors version '3.0.0'

using FHIR version '4.0.1'

define CDCMMEClinicalConversionFactorsCodeSystem:
    CodeSystem {
        name: string { value: 'CDCMMEClinicalConversionFactors' },
        concept: List<FHIR.CodeSystem.Concept> {
            FHIR.CodeSystem.Concept {
                code: code { value: '2670' },
                display: string { value: 'Codeine' },
                property: List<FHIR.CodeSystem."Concept"."Property"> {
                    FHIR.CodeSystem."Concept"."Property" {
                            code: code { value: 'conversion-factor' },
                            value: decimal { value: 0.15 }
                    }
                }
            },
            FHIR.CodeSystem.Concept {
                code: code { value: '4337' },
                display: string { value: 'Fentanyl' },
                property: List<FHIR.CodeSystem."Concept"."Property"> {
                    FHIR.CodeSystem."Concept"."Property" {
                            code: code { value: 'dose-form-conversion-factor' },
                            value: string { value: '316987:7200@0.33333333' }
                    }
                }
            },
            FHIR.CodeSystem.Concept {
                code: code { value: '3423' },
                display: string { value: 'Hydromorphone' },
                property: List<FHIR.CodeSystem."Concept"."Property"> {
                    FHIR.CodeSystem."Concept"."Property" {
                            code: code { value: 'conversion-factor' },
                            value: decimal { value: 4 }
                    }
                }
            },
            FHIR.CodeSystem.Concept {
                code: code { value: '5489' },
                display: string { value: 'Hydrocodone' },
                property: List<FHIR.CodeSystem."Concept"."Property"> {
                    FHIR.CodeSystem."Concept"."Property" {
                            code: code { value: 'conversion-factor' },
                            value: decimal { value: 1 }
                    }
                }
            },
            FHIR.CodeSystem.Concept {
                code: code { value: '6813' },
                display: string { value: 'Methadone' },
                property: List<FHIR.CodeSystem."Concept"."Property"> {
                    FHIR.CodeSystem."Concept"."Property" {
                            code: code { value: 'dose-range-conversion-factor' },
                            value: string { value: '1-20:4' }
                    },
                    FHIR.CodeSystem."Concept"."Property" {
                            code: code { value: 'dose-range-conversion-factor' },
                            value: string { value: '21-40:8' }
                    },
                    FHIR.CodeSystem."Concept"."Property" {
                            code: code { value: 'dose-range-conversion-factor' },
                            value: string { value: '41-60:10' }
                    },
                    FHIR.CodeSystem."Concept"."Property" {
                            code: code { value: 'dose-range-conversion-factor' },
                            value: string { value: '61-*:12' }
                    }
                }
            },
            FHIR.CodeSystem.Concept {
                code: code { value: '7052' },
                display: string { value: 'Morphine' },
                property: List<FHIR.CodeSystem."Concept"."Property"> {
                    FHIR.CodeSystem."Concept"."Property" {
                            code: code { value: 'conversion-factor' },
                            value: decimal { value: 1 }
                    }
                }
            },
            FHIR.CodeSystem.Concept {
                code: code { value: '7804' },
                display: string { value: 'Oxycodone' },
                property: List<FHIR.CodeSystem."Concept"."Property"> {
                    FHIR.CodeSystem."Concept"."Property" {
                            code: code { value: 'conversion-factor' },
                            value: decimal { value: 1.5 }
                    }
                }
            },
            FHIR.CodeSystem.Concept {
                code: code { value: '7814' },
                display: string { value: 'Oxymorphone' },
                property: List<FHIR.CodeSystem."Concept"."Property"> {
                    FHIR.CodeSystem."Concept"."Property" {
                            code: code { value: 'conversion-factor' },
                            value: decimal { value: 3 }
                    }
                }
            }
        }
    }
        
