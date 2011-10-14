R.Transaction = 
  toJSON: ->
    currency: @currency
    amount_in_cents: @cost.cents()
  
  create: createObject
  save: (options) ->
    json = 
      transaction: @toJSON()
      account: (if @account then @account.toJSON() else undefined)
      billing_info: @billingInfo.toJSON()
      signature: options.signature
    
    $.ajax 
      url: R.settings.baseURL + "transactions/create"
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