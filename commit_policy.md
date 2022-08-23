## Commit Policy

All new development takes place on `<feature>` branches off `master`. Once feature development on the branch is complete, the feature branch is submitted to `master` as a PR. The PR is reviewed by maintainers and testing is performed by the reviewer (see the [Testing](#testing) section for more information).

Changes to the `master` branch must be done through an approved PR. Delete branches after merging to keep the repository clean.

### Testing
Testing _MUST_ be performed when a PR contains changes to the CQL or knowledge artifacts. The PR author _SHOULD_ test their changes and the reviewer _MUST_ test the changes before approving and merging the PR. Testing is performed using the Thunder Client test suite located at the root of this project (`thunder-tests` directory). 

Follow the following steps to run the test suite:

1. Install the [Thunder Client](https://www.thunderclient.com) VSCode extension
2. Navigate to the Thunder Client extension by clicking on the lightning bolt icon in the left sidebar menu 
3. Set the `fhirServer` and `cdsHooksServer` environment variables by navigating to the `Env` tab and selecting the `OPIOID_TEST_LOCAL` environment
   - The `fhirServer` variable points to the base URL of a FHIR server (used for transaction operations). Note that this endpoint _MUST_ be the same as the `fhirServer` property defined in the CDS Hooks requests that are being tested. 
   - The `cdsHooksServer` variable points to a CDS Hooks server discovery endpoint
4. Run the _refresh and _updateTestData scripts
   - The result of running these operations _MUST_ be committed to the PR either by the PR author or reviewer
5. Run the test suite by navigating to the `Collections` tab, click the ellipsis next to the `OpioidCDSR4_Test_Suite` collection and select `Run All` 
6. All tests _MUST_ pass before a PR will be approved and merged

To update the test suite, ensure that your Thunder Client extension is configured with [Git Sync](https://github.com/rangav/thunder-client-support#git-sync) 