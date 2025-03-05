const superagent = require("superagent");

const {
  createMedicationRequestWithRef
} = require("./helpers/fhir-resource-helpers");

const FHIR_SERVER = process.env.FHIR_SERVER || "http://localhost:8080/fhir";
const CDS_SERVICE =
  process.env.CDS_SERVICE || "http://localhost:8080/cds-services";
const ORDER_SIGN = "opioidcds-10-order-sign";

const rec10OrderSignUdsMedReqWithRefId = "opioid-10-order-sign-medreq-with-ref";

beforeAll(() => {});

afterAll(() => {});

it("UDS_MED_WITH_REF", async () => {
  const request = {
    hookInstance: rec10OrderSignUdsMedReqWithRefId,
    fhirServer: FHIR_SERVER,
    hook: "order-sign",
    context: {
      patientId: rec10OrderSignUdsMedReqWithRefId,
      encounterId: rec10OrderSignUdsMedReqWithRefId,
      userId: "PractitionerRole/default",
      draftOrders: {
        resourceType: "Bundle",
        type: "collection",
        entry: [
          {
            resource: createMedicationRequestWithRef({
              id: `${rec10OrderSignUdsMedReqWithRefId}-trigger`,
              subjectId: rec10OrderSignUdsMedReqWithRefId,
              medRefId: `${rec10OrderSignUdsMedReqWithRefId}-med-oxycodone`
            })
          },
          {
            resource: createMedicationRequestWithRef({
              id: `${rec10OrderSignUdsMedReqWithRefId}-trigger`,
              subjectId: rec10OrderSignUdsMedReqWithRefId,
              medRefId: `${rec10OrderSignUdsMedReqWithRefId}-med-oxycodone`
            })
          }
        ]
      }
    }
  };

  const resp = await superagent
    .post(`${CDS_SERVICE}/${ORDER_SIGN}`)
    .send(request)
    .set("Accept", "json");

  expect(resp.status).toBe(200);
});
