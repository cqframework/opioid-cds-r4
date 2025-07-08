require("dotenv");

const superagent = require("superagent");
const KNOWLEDGE_ARTIFACTS_BUNDLE = require("../bundles/plandefinition/opioidcds-10-order-sign/opioidcds-10-order-sign-bundle.json");

const FHIR_SERVER = process.env.FHIR_SERVER || "http://localhost:8080/fhir";

const loadKnowledgeArtifacts = () =>
  superagent
    .post(FHIR_SERVER)
    .send(KNOWLEDGE_ARTIFACTS_BUNDLE)
    .set("Accept", "json");

async function setUp() {
  await loadKnowledgeArtifacts();
  console.log("Successfully pushed knowledge artifacts bundle to the server.");
}

module.exports = setUp;
