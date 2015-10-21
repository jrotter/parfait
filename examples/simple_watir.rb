require 'watir-webdriver'

browser = Watir::Browser.new
browser.goto 'xxxx'

# Login 
browser.text_field(:id => 'user_username').when_present.set 'xxxx'
browser.text_field(:id => 'user_password').when_present.set 'xxxx'
browser.button(:id => 'user_submit').when_present.click

# New Message
browser.link(:text => "New Message").when_present.click
browser.text_field(:id => "message_subject").when_present.set "This is my subject"
browser.text_field(:id => "message_body").when_present.set "This is my body"
browser.checkbox(:id => "message_recipients_all_pharmacists").when_present.set
browser.button(:id => "message_submit").when_present.click

# Logout
browser.link(:text => "Log-out").when_present.click


