### Introduction

This implementation guide provides resources and discussion in support of applying the 2016 Centers
for Disease Control and Prevention (CDC) Guideline:

[2016 CDC Guideline for Prescribing Opioids for Chronic Pain](https://www.cdc.gov/mmwr/volumes/65/rr/rr6501e1.htm)

This implementation guide is <u>NOT</u> related to the <a href="https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm">2022 Clinical Practice Guideline for Prescribing Opioids for Pain</a> (2022 Clinical Practice Guideline). The 2022 Clinical Practice Guideline updates and replaces the the 2016 Guideline for Prescribing Opioids for Chronic Pain.

This implementation guide was developed based on work initially done as part of the
<a href="https://confluence.hl7.org/display/CQIWC/Clinical+Quality+Framework">Clinical Quality Framework (CQF)</a>
Initiative, a public-private partnership sponsored by the Centers for Medicare &amp; Medicaid Services (CMS) and
the U.S. Office of the National Coordinator for Health Information Technology (ONC) to identify, develop, and harmonize
standards for clinical decision support and electronic clinical quality measurement, as well as a joint effort by
the Centers for Disease Control and Prevention (CDC) and the Office of the National Coordinator for Health IT (ONC)
focused on improving processes for the development of standardized, shareable, computable decision support artifacts
using the CDC 2016 CDC Guideline as a model case.

Feedback and contributions are welcome and can be submitted using the New Issue link in the footer of every page. Discussions on the
use of this IG as well as other CQF projects take place regularly on the <a href="https://confluence.hl7.org/display/CDS/CPGonFHIR">CPG-on-FHIR calls</a>, a subworkgroup of the HL7 Clinical Decision Support Workgroup.

### Scope

This implementation guide includes support for the following 2016 CDC Guideline recommendations:
* [2016 Opioid Guideline Recommendation #1 - Nonpharmacologic and Nonopioid Pharmacologic Therapy Consideration](recommendation-01.html)
* [2016 Opioid Guideline Recommendation #2 - Opioid Therapy Goals Discussion](recommendation-02.html)
* [2016 Opioid Guideline Recommendation #3 - Opioid Therapy Risk/Benefit Discussion](recommendation-03.html)
* [2016 Opioid Guideline Recommendation #4 - Opioid Immediate Release Form When Starting Opioid Therapy](recommendation-04-order-sign.html)
* [2016 Opioid Guideline Recommendation #5 - Lowest Effective Dose](recommendation-05.html)
* [2016 Opioid Guideline Recommendation #6 - Prescribe Lowest Effective Dose and Duration](recommendation-06.html)
* [2016 Opioid Guideline Recommendation #7 - Opioid Therapy Risk Assessment](recommendation-07.html)
* [2016 Opioid Guideline Recommendation #8 - Naloxone Consideration](recommendation-08.html)
* [2016 Opioid Guideline Recommendation #9 - Consider Patient’s History of Controlled Substance Prescriptions](recommendation-09.html)
* [2016 Opioid Guideline Recommendation #10 - Urine Drug Testing](recommendation-10-order-sign.html)
* [2016 Opioid Guideline Recommendation #11 - Concurrent Use of Opioids and Benzodiazepines](recommendation-11-order-select.html)
* [2016 Opioid Guideline Recommendation #12 - Evidence-based Treatment for Patients with Opioid Use Disorder](recommendation-12.html)  

### Getting Started

For a quick start to get up and running and see how the artifacts work, refer to the [Quick Start](quick-start.html)

For clinical informaticists interested in how the behavior for the artifacts was determined,
refer to the [Process Documentation](process-documentation.html).

For an overview of how the artifacts are represented in the FHIR Clinical Reasoning resources,
refer to the [Integration Documentation](integration-documentation.html).

For a detailed description of how to implement the functionality with CDS Hooks calling into a
FHIR Clinical Reasoning server, refer to the [Implementation Documentation](implementation-documentation.html).

For a detailed description of how to implement the functionality with a Java-based CDS Hooks
service, refer to the [Service Documentation](service-documentation.html).

### Trigger Overview
<div>
    <img src="assets/images/trigger-overview.png" alt="Trigger Overview image">
</div>
<br />

### Morphine Milligram Equivalent (MME) Calculation Cautions

> **Caution**: Do not use the calculated dose in MMEs to determine dosage for converting one opioid to another--the new opioid should be dosed lower to avoid unintentional overdose caused by incomplete cross-tolerance and individual differences in opioid pharmacokinetics. Consult the medication label.

> **Caution**: Dosage thresholds in the 2016 CDC Guideline are based on overdose risk when opioids are prescribed for pain and should not guide dosing of medication treatment for opioid use disorder (i.e., medication-assisted treatment [MAT]).

> **Caution**: Tapentadol is a mu-opioid receptor agonist and norepinephrine reuptake inhibitor. MMEs are based on degree of mu-opioid receptor agonist activity, but it is unknown if this drug is associated with overdose in the same dose-dependent manner as observed with medications that are solely mu-opioid receptor agonists.

> **Extra Caution**:
> * Methadone: the conversion factor increases at higher doses
> * Fentanyl: dosed in mcg/hr instead of mg/day, and absorption is affected by heat and other factors.
