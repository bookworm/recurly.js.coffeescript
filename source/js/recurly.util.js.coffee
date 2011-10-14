R.detectCardType = (cardnumber) ->
  cardnumber = cardnumber.replace(/\D/g, "")
  cards = [ 
    name: "visa"
    prefixes: [ 4 ]
  , 
    name: "mastercard"
    prefixes: [ 51, 52, 53, 54, 55 ]
  , 
    name: "american_express"
    prefixes: [ 34, 37 ]
  , 
    name: "discover"
    prefixes: [ 6011, 62, 64, 65 ]
  , 
    name: "diners_club"
    prefixes: [ 305, 36, 38 ]
  , 
    name: "carte_blanche"
    prefixes: [ 300, 301, 302, 303, 304, 305 ]
  , 
    name: "jcb"
    prefixes: [ 35 ]
  , 
    name: "enroute"
    prefixes: [ 2014, 2149 ]
  , 
    name: "solo"
    prefixes: [ 6334, 6767 ]
  , 
    name: "switch"
    prefixes: [ 4903, 4905, 4911, 4936, 564182, 633110, 6333, 6759 ]
  , 
    name: "maestro"
    prefixes: [ 5018, 5020, 5038, 6304, 6759, 6761 ]
  , 
    name: "visa"
    prefixes: [ 417500, 4917, 4913, 4508, 4844 ]
  , 
    name: "laser"
    prefixes: [ 6304, 6706, 6771, 6709 ]
   ]
  c = 0
  
  while c < cards.length
    p = 0
    
    while p < cards[c].prefixes.length
      return cards[c].name  if new RegExp("^" + cards[c].prefixes[p].toString()).test(cardnumber)
      p++
    c++

R.formatCurrency = (num, denomination) ->
  insertDelimiters = (str) ->
    sRegExp = new RegExp("(-?[0-9]+)([0-9]{3})")
    while sRegExp.test(str)
      str = str.replace(sRegExp, "$1" + langspec.delimiter + "$2")
    str
  if num < 0
    num = -num
    negative = true
  else
    negative = false
  denomination = denomination or R.settings.currency or R.raiseError("currency not configured")
  langspec = R.locale.currency
  currencyspec = R.locale.currencies[denomination]
  str = num.toFixed(currencyspec.precision)
  str = str.replace(/\./g, langspec.separator)  unless langspec.separator == "."
  str = insertDelimiters(str)
  format = langspec.format
  format = format.replace(/%u/g, currencyspec.symbol)
  format = format.replace(/%n/g, str)
  str = format
  str = "-" + str  if negative
  str

euCountries = [ "AT", "BE", "BG", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI", "ES", "SE", "GB" ]
R.isCountryInEU = (country) ->
  $.inArray(country, euCountries) != -1

R.isVATNumberApplicable = (buyerCountry, sellerCountry) ->
  return false  unless R.settings.VATPercent
  R.raiseError "you must configure a country for VAT to work"  unless R.settings.country
  R.raiseError "you cannot charge VAT outside of the EU"  unless R.isCountryInEU(R.settings.country)
  return false  unless R.isCountryInEU(buyerCountry)
  true

R.isVATChargeApplicable = (buyerCountry, vatNumber) ->
  return false  unless R.isVATNumberApplicable(buyerCountry)
  sellerCountry = R.settings.country
  sellerCountry == buyerCountry or not vatNumber

R.flattenErrors = (obj, attr) ->
  arr = []
  baseErrorKeys = [ "base", "account_id" ]
  attr = attr or ""
  if typeof obj == "string" or typeof obj == "number" or typeof obj == "boolean"
    return [ obj ]  if $.inArray(baseErrorKeys, attr)
    return [ "" + attr + " " + obj ]
  for k of obj
    if obj.hasOwnProperty(k)
      attr = (if (parseInt(k).toString() == k) then attr else k)
      children = R.flattenErrors(obj[k], attr)
      i = 0
      l = children.length
      
      while i < l
        arr.push children[i]
        ++i
  arr

R.replaceVars = (str, vars) ->
  for k of vars
    if vars.hasOwnProperty(k)
      v = encodeURIComponent(vars[k])
      str = str.replace(new RegExp("\\{" + k + "\\}", "g"), v)
  str

R.post = (url, params, options) ->
  addParam = (name, value, parent) ->
    fullname = (if parent.length > 0 then (parent + "[" + name + "]") else name)
    if typeof value == "object"
      for i of value
        addParam i, value[i], fullname  if value.hasOwnProperty(i)
    else
      $("<input type=\"hidden\" />").attr(
        name: fullname
        value: value
      ).appendTo form
  if options.resultNamespace
    newParams = {}
    newParams[options.resultNamespace] = params
    params = newParams
  form = $("<form />").hide()
  form.attr("action", url).attr("method", "POST").attr "enctype", "application/x-www-form-urlencoded"
  addParam "", params, ""
  $("body").append form
  form.submit()