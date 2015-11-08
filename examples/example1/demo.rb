require 'watir-webdriver'
require 'parfait'

# Load in the page definition
require './page'

# Get the Application object (which has been pre-set by the control layer)
app = Parfait::Application.find("Sample App")

# Get a Watir browser and point to the sample page
browser = Watir::Browser.new
browser.goto "file://#{ENV['HOME']}/git/parfait/examples/example1/index.html"

# Give the browser object to Parfait
Parfait::set_browser(browser)

# Set a logroutine for Parfait
Parfait::set_logroutine { |logstring|
  puts logstring
}

# Update the "Party" value
app.page("Sample Page").control("Party").update "Republicrat"

# Verify that the "Party" value is what we set it to
app.page("Sample Page").control("Party").verify "Republicrat"

# Submit the change
app.page("Sample Page").control("Set My Party").navigate

# Set a new nickname for President Adams
app.page("Sample Page").region("President" => "John Adams").control("Nickname").update "Sammy's Bro"

# Verify the new nickname for President Adams
app.page("Sample Page").region("President" => "John Adams").control("Nickname").verify "Sammy's Bro"

# View the Biography for President Jefferson
app.page("Sample Page").region("President" => "Thomas Jefferson").control("Biography").navigate
