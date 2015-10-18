require 'watir-webdriver'
require 'parfait'

browser = Watir::Browser.new
browser.goto 'http://staging.eirenerx.com/login'

# Login 
browser.text_field(:name => 'userid').when_present.set 'MUPrescriberman'
browser.text_field(:name => 'password').when_present.set 'Testmd678'
browser.button(:name => 'submit').when_present.click
browser.
