const now = new Date();

const toISOStringNoTz = (date) => date.toISOString().replace("Z", "");

const currentDateTimeNoTz = () => toISOStringNoTz(now);

const addDays = (date, days) =>
  new Date(new Date(date).setDate(date.getDate() + days));

const subtractDays = (date, days) =>
  new Date(new Date(date).setDate(date.getDate() - days));

const getDateTimeMinusDays = (days) => toISOStringNoTz(subtractDays(now, days));

const getDateTimePlusDays = (days) => toISOStringNoTz(addDays(now, days));

const todayDateTime = currentDateTimeNoTz();
const dateTimeMinus30Days = getDateTimeMinusDays(30);
const dateTimePlus30Days = getDateTimePlusDays(30);
const yesterdayDateTime = getDateTimeMinusDays(1);
const nowNoTz = currentDateTimeNoTz();

module.exports = {
  nowNoTz,
  todayDateTime,
  dateTimeMinus30Days,
  dateTimePlus30Days,
  yesterdayDateTime
};
