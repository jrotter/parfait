require 'watir-webdriver'
require 'parfait'

# Define the Application
#
# Your automation will have to do this before loading in the pages,
# as the pages will need to be added to this application
$app = Parfait::Application.new(:name => "My App")

# Load in the page definition
require './page'

# Define the Pages
login = Parfait::Page.new(:name => "Login Page")
eirenerx.add_page(login)
home = Parfait::Page.new(:name => "Home Page")
eirenerx.add_page(home)
message = Parfait::Page.new(:name => "New Message Page")
eirenerx.add_page(message)

# Define the Controls
userid = Parfait::Control.new(:name => "User ID", :logtext => "user ID")
login.add_control(userid)
userid.add_set { |value|
  Parfait::browser.text_field(:id => 'user_username').when_present.set value
}
userid.add_get {
  Parfait::browser.text_field(:id => 'user_username').when_present.value
}

userpw = Parfait::Control.new(:name => "User Password", :logtext => "user password")
login.add_control(userpw)
userpw.add_set { |value|
  Parfait::browser.text_field(:id => 'user_password').when_present.set value
}
userpw.add_get {
  Parfait::browser.text_field(:id => 'user_password').when_present.value
}

signin = Parfait::Control.new(:name => "Sign In", :logtext => "sign in")
login.add_control(signin)
signin.add_goto { 
  Parfait::browser.button(:id => 'user_submit').when_present.click
}

# Configure Parfait logging
Parfait::set_logroutine { |logstring|
  puts logstring
}

# Now run it
browser = Watir::Browser.new
browser.goto 'https://staging.eirenerx.com/'
Parfait::set_browser(browser)

# Login 
eirenerx.page("Login Page").control("User ID").update 'MUPrescriberman'
eirenerx.page("Login Page").control("User ID").retrieve
eirenerx.page("Login Page").control("User ID").confirm 'MUPrescriberman'
eirenerx.page("Login Page").control("User ID").verify 'MUPrescriberman'
eirenerx.page("Login Page").control("User Password").update 'xxxxxxxxx'
eirenerx.page("Login Page").control("Sign In").navigate
#browser.button(:id => 'user_submit').when_present.click

# New Message
#browser.link(:text => "New Message").when_present.click
#browser.text_field(:id => "message_subject").when_present.set "This is my subject"
#browser.text_field(:id => "message_body").when_present.set "This is my body"
#browser.checkbox(:id => "message_recipients_all_pharmacists").when_present.set
#browser.button(:id => "message_submit").when_present.click

# Logout
#browser.link(:text => "Log-out").when_present.click


