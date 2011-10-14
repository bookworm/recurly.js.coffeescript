createObject = (o) ->
  F = ->
  F:: = o or this
  new F()
pluralize = (count, term) ->
  return term.substr(0, term.length - 1)  if count == 1
  "" + count + " " + term
R = {}
R.settings = {}
R.Error = toString: ->
  "RecurlyJS Error: " + @message

R.raiseError = (message) ->
  e = createObject(R.Error)
  e.message = message
  throw e

R.config = (settings) ->
  $.extend true, R.settings, settings
  unless settings.baseURL
    R.settings.baseURL = "https://api.recurly.com/jsonp/"
    subdomain = R.settings.subdomain or R.raiseError("company subdomain not configured")
    R.settings.baseURL += subdomain + "/"

(R.Cost = (cents) ->
  @_cents = cents or 0
):: = 
  toString: ->
    R.formatCurrency @dollars()
  
  cents: (val) ->
    return @_cents  if val == undefined
    new Cost(val)
  
  dollars: (val) ->
    return @_cents / 100  if val == undefined
    new R.Cost(val * 100)
  
  mult: (n) ->
    new R.Cost(@_cents * n)
  
  add: (n) ->
    n = n.cents()  if n.cents
    new R.Cost(@_cents + n)
  
  sub: (n) ->
    n = n.cents()  if n.cents
    new R.Cost(@_cents - n)

R.Cost.FREE = new R.Cost(0)
(R.TimePeriod = (length, unit) ->
  @length = length
  @unit = unit
):: = 
  toString: ->
    "" + pluralize(@length, @unit)
  
  toDate: ->
    d = new Date()
    switch @unit
      when "month"
        d.setMonth d.getMonth() + @length
      when "day"
        d.setDay d.getDay() + @length
    d
  
  clone: ->
    new R.TimePeriod(@length, @unit)

(R.RecurringCost = (cost, interval) ->
  @cost = cost
  @interval = interval
):: = 
  toString: ->
    "" + @cost + " every " + @interval
  
  clone: ->
    new R.TimePeriod(@length, @unit)

R.RecurringCost.FREE = new R.RecurringCost(0, null)
(R.RecurringCostStage = (recurringCost, duration) ->
  @recurringCost = recurringCost
  @duration = duration
):: = toString: ->
  @recurringCost.toString() + " for " + @duration.toString()