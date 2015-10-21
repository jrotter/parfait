require 'watir-webdriver'
require 'parfait'

# Define the Application
eirenerx = Parfait::Application.new(:name => "EireneRx")

# Define the Pages
login = eirenerx.add_page(:label => :login, :text => "login page")
home = eirenerx.add_page(:label => :home, :text => "home page")
message = eirenerx.add_page(:label => :message_new, :text => "new message page")

# Define the Controls
userid = login.add_control(:label => :userid, :text => "user ID")
userid.add_set { |value|
  Thread.current[:parfait_browser].text_field(:id => 'user_username').when_present.set value
}
userid.add_get { |opts|
  Thread.current[:parfait_browser].text_field(:id => 'user_username').when_present.value
}

userid.add_set {
  browser.text_field(:id => 'user_username').when_present.set 'xxxx'
}

# Now run it
browser = Watir::Browser.new
browser.goto 'xxxx'

# Login 
eirenerx.page(:login).control(:userid).set 'xxxx'
#browser.text_field(:id => 'user_password').when_present.set 'xxxx'
#browser.button(:id => 'user_submit').when_present.click

# New Message
#browser.link(:text => "New Message").when_present.click
#browser.text_field(:id => "message_subject").when_present.set "This is my subject"
#browser.text_field(:id => "message_body").when_present.set "This is my body"
#browser.checkbox(:id => "message_recipients_all_pharmacists").when_present.set
#browser.button(:id => "message_submit").when_present.click

# Logout
#browser.link(:text => "Log-out").when_present.click


