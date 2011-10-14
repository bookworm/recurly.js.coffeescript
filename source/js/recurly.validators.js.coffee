wholeNumber = (val) ->
  /^[0-9]+$/.test val
(R.isValidCC = ($input) ->
  v = $input.val()
  return false  if /[^0-9-]+/.test(v)
  nCheck = 0
  nDigit = 0
  bEven = false
  v = v.replace(/\D/g, "")
  n = v.length - 1
  
  while n >= 0
    cDigit = v.charAt(n)
    nDigit = parseInt(cDigit, 10)
    nDigit -= 9  if (nDigit *= 2) > 9  if bEven
    nCheck += nDigit
    bEven = not bEven
    n--
  (nCheck % 10) == 0
).defaultErrorKey = "invalidCC"
(R.isValidEmail = ($input) ->
  v = $input.val()
  /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i.test v
).defaultErrorKey = "invalidEmail"
(R.isValidCVV = ($input) ->
  v = $input.val()
  (v.length == 3 or v.length == 4) and wholeNumber(v)
).defaultErrorKey = "invalidCVV"
(R.isNotEmpty = ($input) ->
  v = $input.val()
  !!v
).defaultErrorKey = "emptyField"
(R.isChecked = ($input) ->
  $input.is ":checked"
).defaultErrorKey = "acceptTOS"