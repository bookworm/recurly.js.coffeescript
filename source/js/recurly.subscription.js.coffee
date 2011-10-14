R.Subscription = 
  create: createObject
  plan: R.Plan
  addOns: []
  calculateTotals: ->
    totals = stages: {}
    totals.plan = @plan.cost.mult(@plan.quantity)
    totals.allAddOns = new R.Cost(0)
    totals.addOns = {}
    l = @addOns.length
    i = 0
    
    while i < l
      a = @addOns[i]
      c = a.cost.mult(a.quantity)
      totals.addOns[a.code] = c
      totals.allAddOns = totals.allAddOns.add(c)
      ++i
    totals.stages.recurring = totals.plan.add(totals.allAddOns)
    totals.stages.now = totals.plan.add(totals.allAddOns)
    totals.stages.now = R.Cost.FREE  if @plan.trial
    totals.stages.now = totals.stages.now.add(@plan.setupFee)  if @plan.setupFee
    if @coupon
      beforeDiscount = totals.stages.now
      afterDiscount = totals.stages.now.discount(@coupon)
      totals.coupon = afterDiscount.sub(beforeDiscount)
      totals.stages.now = afterDiscount
    if @billingInfo and R.isVATChargeApplicable(@billingInfo.country, @billingInfo.vatNumber)
      totals.vat = totals.stages.now.mult((R.settings.VATPercent / 100))
      totals.stages.now = totals.stages.now.add(totals.vat)
    totals
  
  redeemAddOn: (addOn) ->
    redemption = addOn.createRedemption()
    @addOns.push redemption
    redemption
  
  removeAddOn: (code) ->
    a = @addOns
    l = a.length
    i = 0
    
    while i < l
      return a.splice(i, 1)  if a[i].code == code
      ++i
  
  findAddOnByCode: (code) ->
    l = @addOns.length
    i = 0
    
    while i < l
      return @addOns[i]  if @addOns[i].code == code
      ++i
    false
  
  toJSON: ->
    json = 
      plan_code: @plan.code
      quantity: @plan.quantity
      coupon_code: (if @coupon then @coupon.code else undefined)
      add_ons: []
    
    i = 0
    l = @addOns.length
    a = json.add_ons
    b = @addOns
    
    while i < l
      a.push 
        add_on_code: b[i].code
        quantity: b[i].quantity
      ++i
    json
  
  save: (options) ->
    json = 
      subscription: @toJSON()
      account: @account.toJSON()
      billing_info: @billingInfo.toJSON()
    
    $.ajax 
      url: R.settings.baseURL + "subscribe"
      data: json
      dataType: "jsonp"
      jsonp: "callback"
      timeout: 60000
      success: (data) ->
        if data.success and options.success
          options.success data.success
        else if data.errors and options.error
          errorCode = data.errors.error_code
          delete data.errors.error_code
          
          options.error R.flattenErrors(data.errors), errorCode
      
      error: ->
        options.error [ "Unknown error processing transaction. Please try again later." ]  if options.error
      
      complete: options.complete

R.AddOn.createRedemption = (qty) ->
  r = createObject(this)
  r.quantity = qty or 1
  r

R.Coupon = 
  fromJSON: (json) ->
    c = createObject(R.Coupon)
    if json.discount_in_cents
      c.discountCost = new R.Cost(-json.discount_in_cents)
    else c.discountRatio = json.discount_percent / 100  if json.discount_percent
    c.description = json.description
    c
  
  toJSON: ->

R.Cost::discount = (coupon) ->
  return @add(coupon.discountCost)  if coupon.discountCost
  ret = @sub(@mult(coupon.discountRatio))
  return R.Cost.FREE  if ret.cents() < 0
  ret

R.Subscription.getCoupon = (couponCode, successCallback, errorCallback) ->
  R.raiseError "Company subdomain not configured"  unless R.settings.baseURL
  $.ajax 
    url: R.settings.baseURL + "plans/" + @plan.code + "/coupons/" + couponCode
    dataType: "jsonp"
    jsonp: "callback"
    timeout: 10000
    success: (data) ->
      if data.valid
        coupon = R.Coupon.fromJSON(data)
        coupon.code = couponCode
        successCallback coupon
      else
        errorCallback()
    
    error: ->
      errorCallback()