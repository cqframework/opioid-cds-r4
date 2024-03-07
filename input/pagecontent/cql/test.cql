library test version '1.0'

using FHIR version '4.0.1'

parameter Count default {}

define testPositiveDateList:
  { @2024-01-01, @2024-02-04 }
define testPositiveDateList1:
  { @2024-02-04, @2024-01-01, @2023-12-01 }
define testPositiveIngredientList:
  { 'Cocaine', 'PCP' }

define testScreeningList:
  {
    Tuple {
      ingredient: 'Cocaine',
      date: @2024-01-01
    },
    Tuple {
      ingredient: 'Cocaine',
      date: @2024-02-04
    },
    Tuple {
      ingredient: 'PCP',
      date: @2024-02-04
    }
  }

define testScreeningList1:
  {
    Tuple {
      ingredient: 'Cocaine',
      dates: { @2024-01-01, @2024-02-04 }
    },
    Tuple {
      ingredient: 'PCP',
      dates: { @2024-02-04 }
    }
  }

define testDetail:
  {
    ingredient: 'Cocaine',
    screenings: {
      {
        date: @2024-02-04,
        detailedIdentifier: 'Codeine [Presence] in Urine'
      },
      {
        date: @2024-01-01,
        detailedIdentifier: 'Codeine [Presence] in Urine'
      },
      {
        date: @2023-12-01,
        detailedIdentifier: 'Blah blah blah'
      }
    }
  }

define function increment():
  Count union {1}

define testCount:
  {'⌀', '∀', '∞', '∃', '∇', '^', '∫', '∝'}

define testCounter:
  testDetail Detail
    return all (
      "Table Row Start" + "Table Cell Normal Start" + Detail.ingredient + "Table Cell End" +
      Combine(
        testPositiveDateList1 positiveDate
          return all (
            if Detail.screenings.date contains positiveDate
              then "Table Cell Unexpected Start" + 'pos' + "Table Cell End"
            else "Table Cell Normal Start" + 'neg' + "Table Cell End"
          )
      )
      + "Table Row End"
    )

define testUnexpectedRows1:
  testScreeningList Screenings
    return all (
      "Table Row Start" + "Table Cell Normal Start" + Screenings.ingredient + "Table Cell End"
      + (
        (IndexOf(testPositiveDateList, Screenings.date)) Idx 
          return (
            if Idx = -1
              then "Table Cell Normal Start" + 'neg' + "Table Cell End"
            else "Table Cell Unexpected Start" + 'pos' + "Table Cell End"
          )
      ) + "Table Row End"
    )

define testUnexpectedRows2:
  testScreeningList Screenings
    return all (
      "Table Row Start" + "Table Cell Normal Start" + Screenings.ingredient + "Table Cell End"
      + (
        if IndexOf(testPositiveDateList, Screenings.date) = -1
          then "Table Cell Normal Start" + 'neg' + "Table Cell End"
        else "Table Cell Unexpected Start" + 'pos' + "Table Cell End"         
      ) + "Table Row End"
    )

define testUnexpectedRows3:
  from
  testScreeningList Screenings,
  testPositiveDateList positiveDate
    return (
      "Table Row Start" + "Table Cell Normal Start" + Screenings.ingredient + "Table Cell End"
      + (
        if positiveDate same day as Screenings.date
          then "Table Cell Normal Start" + 'neg' + "Table Cell End"
        else "Table Cell Unexpected Start" + 'pos' + "Table Cell End"
      ) + "Table Row End"
    )

define testUnexpectedRows4:
  testPositiveDateList positiveDate
    return all (
      "Table Row Start" + "Table Cell Normal Start" + 'Cocaine' + "Table Cell End"
      + (
        Combine(testScreeningList Screenings
          return (
            if positiveDate same day as Screenings.date
              then "Table Cell Normal Start" + 'neg' + "Table Cell End"
            else "Table Cell Unexpected Start" + 'pos' + "Table Cell End"
          )
        )
      ) + "Table Row End"
    )

define testUnexpectedRows5:
  testPositiveDateList positiveDate
    return (
      Combine(testScreeningList1 Screenings
        return (
          "Table Row Start" + "Table Cell Normal Start" + Screenings.ingredient + "Table Cell End" +
          (
            if Screenings.dates contains positiveDate
              then "Table Cell Unexpected Start" + 'pos' + "Table Cell End"
            else "Table Cell Normal Start" + 'neg' + "Table Cell End"
          )
          + "Table Row End"
        )
      )
    )

define testUnexpectedRows6:
  from testPositiveDateList positiveDate,
  testScreeningList1 Screenings
    return all (
      "Table Row Start" + "Table Cell Normal Start" + Screenings.ingredient + "Table Cell End" +
      (
        if Screenings.dates contains positiveDate
          then "Table Cell Unexpected Start" + 'pos' + "Table Cell End"
        else "Table Cell Normal Start" + 'neg' + "Table Cell End"
      )
      + "Table Row End"
    )

define testUnexpectedRows7:
  testScreeningList1 Screenings
    return all (
      "Table Row Start" + "Table Cell Normal Start" + Screenings.ingredient + "Table Cell End" +
      Combine(
        testPositiveDateList positiveDate
          return all (
            if Screenings.dates contains positiveDate
              then "Table Cell Unexpected Start" + 'pos' + "Table Cell End"
            else "Table Cell Normal Start" + 'neg' + "Table Cell End"
          )
      )
      + "Table Row End"
    )

define "Table Cell Unexpected Start":
  '<td class=\"details-table-cell-unexpected\">'

define "Table Cell Normal Start":
  '<td class=\"details-table-cell\">'

define "Table Cell End":
  '<\/td>'

define "Table Row Start":
  '<tr>'

define "Table Row End":
  '<\/tr>'