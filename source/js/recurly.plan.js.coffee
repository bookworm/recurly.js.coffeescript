R.Plan = 
  create: createObject
  fromJSON: (json) ->
    p = @create()
    p.name = json.name
    p.code = json.plan_code
    p.cost = new R.Cost(json.unit_amount_in_cents)
    p.displayQuantity = json.display_quantity
    p.interval = new R.TimePeriod(json.plan_interval_length, json.plan_interval_unit)
    p.trial = new R.TimePeriod(json.trial_interval_length, json.trial_interval_unit)  if json.trial_interval_length
    p.setupFee = new R.Cost(json.setup_fee_in_cents)  if json.setup_fee_in_cents
    p.addOns = []
    if json.add_ons
      l = json.add_ons.length
      i = 0
      
      while i < l
        a = json.add_ons[i]
        p.addOns.push R.AddOn.fromJSON(a)
        ++i
    p
  
  get: (plan_code, callback) ->
    $.ajax 
      url: R.settings.baseURL + "plans/" + plan_code
      dataType: "jsonp"
      jsonp: "callback"
      timeout: 10000
      success: (data) ->
        plan = R.Plan.fromJSON(data)
        callback plan
  
  createSubscription: ->
    s = createObject(R.Subscription)
    s.plan = createObject(this)
    s.plan.quantity = 1
    s.addOns = []
    s

R.AddOn = 
  fromJSON: (json) ->
    a = createObject(R.AddOn)
    a.name = json.name
    a.code = json.add_on_code
    a.cost = new R.Cost(json.default_unit_amount_in_cents)
    a.displayQuantity = json.display_quantity
    a
  
  toJSON: ->
    name: @name
    add_on_code: @code
    default_unit_amount_in_cents: @default_unit_amount_in_cents