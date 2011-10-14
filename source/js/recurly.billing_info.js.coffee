R.BillingInfo = 
  create: createObject
  toJSON: ->
    first_name: @firstName
    last_name: @lastName
    month: @month
    year: @year
    number: @number
    verification_value: @cvv
    address1: @address1
    address2: @address2
    city: @city
    state: @state
    zip: @zip
    country: @country
    phone: @phone
  
  save: (options) ->
    json = 
      billing_info: @toJSON()
      signature: options.signature
    
    unless options.distinguishContactFromBillingInfo
      json.account = 
        account_code: options.accountCode
        first_name: @firstName
        last_name: @lastName
    $.ajax 
      url: R.settings.baseURL + "accounts/" + options.accountCode + "/billing_info/update"
      data: json
      dataType: "jsonp"
      jsonp: "callback"
      timeout: 60000
      success: (data) ->
        if data.success and options.success
          options.success data.success
        else options.error R.flattenErrors(data.errors)  if data.errors and options.error
      
      error: ->
        options.error [ "Unknown error processing transaction. Please try again later." ]  if options.error
      
      complete: options.complete or $.noop