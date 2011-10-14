C = (key, def) ->
  c = R.locale.currencies[key] = createObject(R.locale.currency)
  for p of def
    c[p] = def[p]
R.locale = {}
R.locale.errors = 
  emptyField: "Required field"
  missingFullAddress: "Please enter your full address."
  invalidEmail: "Invalid"
  invalidCC: "Invalid"
  invalidCVV: "Invalid"
  invalidCoupon: "Invalid"
  cardDeclined: "Transaction declined"
  acceptTOS: "Please accept the Terms of Service."

R.locale.currencies = {}
R.locale.currency = 
  format: "%u%n"
  separator: "."
  delimiter: ","
  precision: 2

C "USD", symbol: "$"
C "AUD", symbol: "$"
C "CAD", symbol: "$"
C "EUR", symbol: "€"
C "GBP", symbol: "£"
C "CZK", symbol: "K"
C "DKK", symbol: "歲"
C "HUF", symbol: "Ft"
C "JPY", symbol: "¥"
C "NOK", symbol: "kr"
C "NZD", symbol: "$"
C "PLN", symbol: "z"
C "SGD", symbol: "$"
C "SEK", symbol: "kr"
C "CHF", symbol: "Fr"
C "ZAR", symbol: "R"
R.settings.locale = R.locale