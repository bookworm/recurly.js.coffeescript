raiseUserError = (validation, elem) ->
  e = createObject(R.UserError)
  e.validation = validation
  e.element = elem
  throw e
handleUserErrors = (block) ->
  try
    block()
  catch e
    throw e  unless e.validation
    $input = e.element
    message = R.locale.errors[e.validation.errorKey]
    validator = e.validation.validator
    $e = $("<div class=\"error\">")
    $e.text message
    $e.appendTo $input.parent()
    $input.addClass "invalid"
    $input.bind "change keyup", ->
      if validator($input)
        $input.removeClass "invalid"
        $e.remove()
        $input.unbind()
    
    $input.focus()
getField = ($form, fieldSel, validation) ->
  $input = $form.find(fieldSel + " input")
  $input = $form.find(fieldSel + " select")  if $input.length == 0
  return undefined  if $input.length == 0
  val = $input.val()
  i = 2
  
  while v = arguments[i]
    raiseUserError v, $input  unless v.validator($input)
    ++i
  val
V = (v, k) ->
  validator: v
  errorKey: k or v.defaultErrorKey
clearServerErrors = ($form) ->
  $serverErrors = $form.find(".server_errors")
  $serverErrors.removeClass("any").addClass "none"
  $serverErrors.empty()
displayServerErrors = ($form, errors) ->
  $serverErrors = $form.find(".server_errors")
  clearServerErrors $form
  l = errors.length
  if l
    $serverErrors.removeClass("none").addClass "any"
    i = 0
    
    while i < l
      $e = $("<div class=\"error\">")
      $e.text errors[i]
      $serverErrors.append $e
      ++i
preFillValues = ($form, preFill, mapObject) ->
  return  unless preFill
  for k of preFill
    if preFill.hasOwnProperty(k) and mapObject.hasOwnProperty(k)
      v = preFill[k]
      selectorOrNested = mapObject[k]
      if typeof selectorOrNested == "string"
        $form.find(selectorOrNested).val(v).change()
      else preFillValues $form, v, selectorOrNested  if typeof selectorOrNested == "object"
initCommonForm = ($form, options) ->
  $form.find(".phone").remove()  unless options.collectPhone
  $form.find(".company_name").remove()  unless options.collectCompany
  $form.delegate ".placeholder", "click", ->
    $label = $(this)
    $li = $(this).parent()
    $li.find("input").focus()
  
  $form.delegate "input", "change keyup", ->
    $input = $(this)
    $li = $(this).parent()
    if $input.val().length > 0
      $li.find(".placeholder").hide()
    else
      $li.find(".placeholder").show()
  
  $form.delegate "input", "focus", ->
    $(this).parent().addClass "focus"
  
  $form.delegate "input", "blur", ->
    $(this).parent().removeClass "focus"
  
  $form.delegate "input", "keydown", (e) ->
    $(this).parent().find(".placeholder").hide()  if e.keyCode >= 48 and e.keyCode <= 90
  
  preFillValues $form, options.preFill, preFillMap
initContactInfoForm = ($form, options) ->
  if options.distinguishContactFromBillingInfo
    $contactFirstName = $form.find(".contact_info .first_name input")
    $contactLastName = $form.find(".contact_info .last_name input")
    prevFirstName = $contactFirstName.val()
    prevLastName = $contactLastName.val()
    $form.find(".contact_info .first_name input").change ->
      $billingFirstName = $form.find(".billing_info .first_name input")
      $billingFirstName.val($(this).val()).change()  if $billingFirstName.val() == prevFirstName
      prevFirstName = $contactFirstName.val()
    
    $form.find(".contact_info .last_name input").change ->
      $billingLastName = $form.find(".billing_info .last_name input")
      $billingLastName.val($(this).val()).change()  if $billingLastName.val() == prevLastName
      prevLastName = $contactLastName.val()
  else
    $form.find(".billing_info .first_name, .billing_info .last_name").remove()
initBillingInfoForm = ($form, options) ->
  updateMonths = ->
    if $yearSelect.val() == year
      $monthSelect.find "option[value=\"" + month + "\"]"
      foundSelected = false
      $monthSelect.find("option").each ->
        if $(this).val() <= month
          $(this).attr "disabled", true
        else
          $(this).removeAttr "disabled"
          unless foundSelected
            foundSelected = true
            $(this).attr "selected", true
    else
      $monthSelect.find("option").removeAttr "disabled"
  if R.settings.country
    $countryOpt = $form.find(".country option[value=" + R.settings.country + "]")
    $countryOpt.attr("selected", true).change()  if $countryOpt.length
  now = new Date()
  year = now.getFullYear()
  month = now.getMonth()
  $yearSelect = $form.find(".year select")
  $monthSelect = $form.find(".month select")
  i = year
  
  while i <= year + 10
    $yearOpt = $("<option name=\"" + i + "\">" + i + "</option>")
    $yearOpt.appendTo $yearSelect
    ++i
  $yearSelect.val year + 1
  updateMonths()
  $yearSelect.change updateMonths
  if options.addressRequirement == "none"
    $form.find(".address").remove()
  else if options.addressRequirement == "zip"
    $form.find(".address").addClass "only_zip"
    $form.find(".address1, .address2, .city, .state").remove()
    $form.find(".country").remove()  unless R.settings.VATPercent
  else if options.addressRequirement == "zipstreet"
    $form.find(".address").addClass "only_zipstreet"
    $form.find(".city, .state").remove()
    $form.find(".country").remove()  unless R.settings.VATPercent
  else $form.find(".address").addClass "full"  if options.addressRequirement == "full"
  $acceptedCards = $form.find(".accepted_cards")
  $form.find(".card_number input").bind "change keyup", ->
    type = R.detectCardType($(this).val())
    if type
      $acceptedCards.find(".card").each ->
        $(this).toggleClass "match", $(this).hasClass(type)
        $(this).toggleClass "no_match", not $(this).hasClass(type)
    else
      $acceptedCards.find(".card").removeClass "match no_match"
pullAccountFields = ($form, account, options) ->
  account.firstName = getField($form, ".contact_info .first_name", V(R.isNotEmpty))
  account.lastName = getField($form, ".contact_info .last_name", V(R.isNotEmpty))
  account.companyName = getField($form, ".contact_info .company_name")
  account.email = getField($form, ".email", V(R.isNotEmpty), V(R.isValidEmail))
  account.code = options.accountCode
pullBillingInfoFields = ($form, billingInfo, options) ->
  billingInfo.firstName = getField($form, ".billing_info .first_name", V(R.isNotEmpty))
  billingInfo.lastName = getField($form, ".billing_info .last_name", V(R.isNotEmpty))
  billingInfo.number = getField($form, ".card_number", V(R.isNotEmpty), V(R.isValidCC))
  billingInfo.cvv = getField($form, ".cvv", V(R.isNotEmpty), V(R.isValidCVV))
  billingInfo.month = getField($form, ".month")
  billingInfo.year = getField($form, ".year")
  billingInfo.phone = getField($form, ".phone")
  billingInfo.address1 = getField($form, ".address1", V(R.isNotEmpty))
  billingInfo.address2 = getField($form, ".address2")
  billingInfo.city = getField($form, ".city", V(R.isNotEmpty))
  billingInfo.state = getField($form, ".state", V(R.isNotEmpty))
  billingInfo.zip = getField($form, ".zip", V(R.isNotEmpty))
  billingInfo.country = getField($form, ".country", V((v) ->
    v.val() != "-"
  , "emptyField"))
verifyTOSChecked = ($form) ->
  getField $form, ".accept_tos", V(R.isChecked)
initTOSCheck = ($form, options) ->
  if options.termsOfServiceURL or options.privacyPolicyURL
    $tos = $form.find(".accept_tos").html(R.termsOfServiceHTML)
    $tos.find("span.and").remove()  unless (options.termsOfServiceURL and options.privacyPolicyURL)
    if options.termsOfServiceURL
      $tos.find("a.tos_link").attr "href", options.termsOfServiceURL
    else
      $tos.find("a.tos_link").remove()
    if options.privacyPolicyURL
      $tos.find("a.pp_link").attr "href", options.privacyPolicyURL
    else
      $tos.find("a.pp_link").remove()
  else
    $form.find(".accept_tos").remove()
R.UserError = {}
preFillMap = 
  contactInfo: 
    firstName: ".contact_info > .full_name > .first_name > input"
    lastName: ".contact_info > .full_name > .last_name > input"
    email: ".contact_info > .email > input"
    phone: ".contact_info > .phone > input"
    companyName: ".contact_info > .company_name > input"
  
  billingInfo: 
    firstName: ".billing_info > .credit_card > .first_name > input"
    lastName: ".billing_info > .credit_card > .last_name > input"
    address1: ".billing_info > .address > .address1 > input"
    address2: ".billing_info > .address > .address2 > input"
    country: ".billing_info > .address > .country > select"
    city: ".billing_info > .address > .city > input"
    state: ".billing_info > .address > .state_zip > .state > input"
    zip: ".billing_info > .address > .state_zip > .zip > input"
    vatNumber: ".billing_info > .vat_number > input"

R.buildBillingInfoUpdateForm = (options) ->
  defaults = 
    addressRequirement: "full"
    distinguishContactFromBillingInfo: true
  
  options = $.extend(createObject(R.settings), defaults, options)
  R.raiseError "accountCode missing"  unless options.accountCode
  R.raiseError "signature missing"  unless options.signature
  billingInfo = R.BillingInfo.create()
  $form = $(R.updateBillingInfoFormHTML)
  $form.find(".billing_info").html R.billingInfoFieldsHTML
  initCommonForm $form, options
  initBillingInfoForm $form, options
  $form.submit (e) ->
    e.preventDefault()
    clearServerErrors $form
    $form.find(".error").remove()
    $form.find(".invalid").removeClass "invalid"
    handleUserErrors ->
      pullBillingInfoFields $form, billingInfo, options
      $form.addClass "submitting"
      $form.find("button.submit").attr("disabled", true).text "Please Wait"
      billingInfo.save 
        signature: options.signature
        distinguishContactFromBillingInfo: options.distinguishContactFromBillingInfo
        accountCode: options.accountCode
        success: (response) ->
          options.afterUpdate response  if options.afterUpdate
          if options.successURL
            url = options.successURL
            R.post url, response, options
        
        error: (errors) ->
          displayServerErrors $form, errors  if not options.onError or not options.onError(errors)
        
        complete: ->
          $form.removeClass "submitting"
          $form.find("button.submit").removeAttr("disabled").text "Update"
  
  options.beforeInject $form.get(0)  if options.beforeInject
  $ ->
    $container = $(options.target)
    $container.html $form
    options.afterInject $form.get(0)  if options.afterInject

R.buildTransactionForm = (options) ->
  defaults = 
    addressRequirement: "full"
    distinguishContactFromBillingInfo: true
    collectContactInfo: true
  
  options = $.extend(createObject(R.settings), defaults, options)
  R.raiseError "collectContactInfo is false, but no accountCode provided"  if not options.collectContactInfo and not options.accountCode
  R.raiseError "signature missing"  unless options.signature
  billingInfo = R.BillingInfo.create()
  account = R.Account.create()
  transaction = R.Transaction.create()
  transaction.account = account
  transaction.billingInfo = billingInfo
  transaction.currency = options.currency
  transaction.cost = new R.Cost(options.amountInCents)
  $form = $(R.oneTimeTransactionFormHTML)
  $form.find(".billing_info").html R.billingInfoFieldsHTML
  if options.collectContactInfo
    $form.find(".contact_info").html R.contactInfoFieldsHTML
  else
    $form.find(".contact_info").remove()
  initCommonForm $form, options
  initContactInfoForm $form, options
  initBillingInfoForm $form, options
  initTOSCheck $form, options
  $form.submit (e) ->
    e.preventDefault()
    clearServerErrors $form
    $form.find(".error").remove()
    $form.find(".invalid").removeClass "invalid"
    handleUserErrors ->
      pullAccountFields $form, account, options
      pullBillingInfoFields $form, billingInfo, options
      verifyTOSChecked $form
      $form.addClass "submitting"
      $form.find("button.submit").attr("disabled", true).text "Please Wait"
      transaction.save 
        signature: options.signature
        accountCode: options.accountCode
        success: (response) ->
          options.afterPay response  if options.afterPay
          if options.successURL
            url = options.successURL
            R.post url, response, options
        
        error: (errors) ->
          displayServerErrors $form, errors  if not options.onError or not options.onError(errors)
        
        complete: ->
          $form.removeClass "submitting"
          $form.find("button.submit").removeAttr("disabled").text "Pay"
  
  options.beforeInject $form.get(0)  if options.beforeInject
  $ ->
    $container = $(options.target)
    $container.html $form
    options.afterInject $form.get(0)  if options.afterInject

R.buildSubscriptionForm = (options) ->
  gotPlan = (plan) ->
    updateTotals = ->
      totals = subscription.calculateTotals()
      $form.find(".plan .recurring_cost .cost").text "" + totals.plan
      $form.find(".due_now .cost").text "" + totals.stages.now
      $form.find(".coupon .discount").text "" + (totals.coupon or "")
      $form.find(".vat .cost").text "" + (totals.vat or "")
      $form.find(".add_ons .add_on").each ->
        addOn = $(this).data("add_on")
        if $(this).hasClass("selected")
          cost = totals.addOns[addOn.code]
          $(this).find(".cost").text "+ " + cost
        else
          $(this).find(".cost").text "+ " + addOn.cost
    updateCoupon = ->
      code = $coupon.find("input").val()
      return  if code == lastCode
      lastCode = code
      unless code
        $coupon.removeClass("invalid").removeClass "valid"
        $coupon.find(".description").text ""
        subscription.coupon = undefined
        updateTotals()
        return
      $coupon.addClass "checking"
      subscription.getCoupon code, ((coupon) ->
        $coupon.removeClass "checking"
        subscription.coupon = coupon
        $coupon.removeClass("invalid").addClass "valid"
        $coupon.find(".description").text coupon.description
        updateTotals()
      ), ->
        subscription.coupon = undefined
        $coupon.removeClass "checking"
        $coupon.removeClass("valid").addClass "invalid"
        $coupon.find(".description").text "Not Found"
        updateTotals()
    showHideVAT = ->
      buyerCountry = $form.find(".country select").val()
      vatNumberApplicable = R.isVATNumberApplicable(buyerCountry)
      $vatNumber.toggleClass "applicable", vatNumberApplicable
      $vatNumber.toggleClass "inapplicable", not vatNumberApplicable
      vatNumber = $vatNumberInput.val()
      chargeApplicable = R.isVATChargeApplicable(buyerCountry, vatNumber)
      $vat.toggleClass "applicable", chargeApplicable
      $vat.toggleClass "inapplicable", not chargeApplicable
    plan = options.filterPlan(plan) or plan  if options.filterPlan
    subscription = plan.createSubscription()
    account = R.Account.create()
    billingInfo = R.BillingInfo.create()
    subscription.account = account
    subscription.billingInfo = billingInfo
    subscription = options.filterSubscription(subscription) or subscription  if options.filterSubscription
    $form.find(".plan .quantity").remove()  unless plan.displayQuantity
    if plan.setupFee
      $form.find(".subscription").addClass "with_setup_fee"
      $form.find(".plan .setup_fee .cost").text "" + plan.setupFee
    else
      $form.find(".plan .setup_fee").remove()
    if plan.trial
      $form.find(".subscription").addClass "with_trial"
      $form.find(".plan .free_trial").text "First " + plan.trial + " free"
    else
      $form.find(".plan .free_trial").remove()
    $form.find(".plan .quantity input").bind "change keyup", ->
      subscription.plan.quantity = parseInt($(this).val(), 10) or 1
      updateTotals()
    
    $form.find(".plan .name").text plan.name
    $form.find(".plan .recurring_cost .cost").text "" + plan.cost
    $form.find(".plan .recurring_cost .interval").text "every " + plan.interval
    $addOnsList = $form.find(".add_ons")
    if options.enableAddOns
      l = plan.addOns.length
      if l
        $addOnsList.removeClass("none").addClass "any"
        i = 0
        
        while i < l
          addOn = plan.addOns[i]
          classAttr = "add_on add_on_" + addOn.code + (if i % 2 then " even" else " odd")
          classAttr += " first"  if i == 0
          classAttr += " last"  if i == l - 1
          $addOn = $("<div class=\"" + classAttr + "\">" + "<div class=\"name\">" + addOn.name + "</div>" + "<div class=\"field quantity\">" + "<div class=\"placeholder\">Qty</div>" + "<input type=\"text\">" + "</div>" + "<div class=\"cost\"/>" + "</div>")
          $addOn.find(".quantity").remove()  unless addOn.displayQuantity
          $addOn.data "add_on", addOn
          $addOn.appendTo $addOnsList
          ++i
        $addOnsList.delegate ".add_ons .quantity input", "change keyup", (e) ->
          $addOn = $(this).closest(".add_on")
          addOn = $addOn.data("add_on")
          newQty = parseInt($(this).val(), 10) or 1
          subscription.findAddOnByCode(addOn.code).quantity = newQty
          updateTotals()
        
        $addOnsList.bind "selectstart", (e) ->
          e.preventDefault()  if $(e.target).is(".add_on")
        
        $addOnsList.delegate ".add_ons .add_on", "click", (e) ->
          return  if $(e.target).closest(".quantity").length
          selected = not $(this).hasClass("selected")
          $(this).toggleClass "selected", selected
          addOn = $(this).data("add_on")
          if selected
            sa = subscription.redeemAddOn(addOn)
            $qty = $(this).find(".quantity input")
            sa.quantity = parseInt($qty.val(), 10) or 1
            $qty.focus()
          else
            subscription.removeAddOn addOn.code
          updateTotals()
    else
      $addOnsList.remove()
    $coupon = $form.find(".coupon")
    lastCode = null
    if options.enableCoupons
      $coupon.find("input").bind "keyup change", (e) ->
      
      $coupon.find("input").keypress (e) ->
        if e.charCode == 13
          e.preventDefault()
          updateCoupon()
      
      $coupon.find(".check").click ->
        updateCoupon()
      
      $coupon.find("input").blur ->
        $coupon.find(".check").click()
    else
      $coupon.remove()
    $vat = $form.find(".vat")
    $vatNumber = $form.find(".vat_number")
    $vatNumberInput = $vatNumber.find("input")
    $vat.find(".title").text "VAT at " + R.settings.VATPercent + "%"
    $form.find(".country select").change(->
      billingInfo.country = $(this).val()
      updateTotals()
      showHideVAT()
    ).change()
    $vatNumberInput.bind "keyup change", ->
      billingInfo.vatNumber = $(this).val()
      updateTotals()
      showHideVAT()
    
    $form.submit (e) ->
      e.preventDefault()
      clearServerErrors $form
      $form.find(".error").remove()
      $form.find(".invalid").removeClass "invalid"
      handleUserErrors ->
        pullAccountFields $form, account, options
        pullBillingInfoFields $form, billingInfo, options
        verifyTOSChecked $form
        $form.addClass "submitting"
        $form.find("button.submit").attr("disabled", true).text "Please Wait"
        subscription.save 
          success: (response) ->
            options.afterSubscribe response  if options.afterSubscribe
            if options.successURL
              url = options.successURL
              R.post url, response, options
          
          error: (errors) ->
            displayServerErrors $form, errors  if not options.onError or not options.onError(errors)
          
          complete: ->
            $form.removeClass "submitting"
            $form.find("button.submit").removeAttr("disabled").text "Subscribe"
    
    updateTotals()
    options.beforeInject $form.get(0)  if options.beforeInject
    $ ->
      $container = $(options.target)
      $container.html $form
      options.afterInject $form.get(0)  if options.afterInject
  defaults = 
    enableAddOns: true
    enableCoupons: true
    addressRequirement: "full"
    distinguishContactFromBillingInfo: false
  
  options = $.extend(createObject(R.settings), defaults, options)
  $form = $(R.subscribeFormHTML)
  $form.find(".contact_info").html R.contactInfoFieldsHTML
  $form.find(".billing_info").html R.billingInfoFieldsHTML
  initCommonForm $form, options
  initContactInfoForm $form, options
  initBillingInfoForm $form, options
  initTOSCheck $form, options
  if options.planCode
    R.Plan.get options.planCode, gotPlan
  else gotPlan options.plan  if options.plan