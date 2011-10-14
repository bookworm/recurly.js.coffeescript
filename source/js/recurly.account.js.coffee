R.Account = 
  create: createObject
  toJSON: ->
    first_name: @firstName
    last_name: @lastName
    company_name: @companyName
    account_code: @code
    email: @email