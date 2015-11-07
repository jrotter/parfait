# Define the Page
sample_page = Parfait::Page.new(:name => "Sample Page")

# Add the page to our application
$app.add_page(login)


########################################
# Define the party selection control
########################################
party = Parfait::Control.new(:name => "Party", :logtext => "political party")

# Add our new control to the page
sample_page.add_control(party)

# Define a "get" for the control
party.add_get {
  retval = nil
  retval = Parfait::browser.div(:id => "radio-example").radio(:value => "Federalist").set? ? "Federalist" : retval
  retval = Parfait::browser.div(:id => "radio-example").radio(:value => "Democrat").set? ? "Democrat" : retval
  retval = Parfait::browser.div(:id => "radio-example").radio(:value => "Republican").set? ? "Republican" : retval
  retval = Parfait::browser.div(:id => "radio-example").radio(:value => "Republicrat").set? ? "Republicrat" : retval
  retval = Parfait::browser.div(:id => "radio-example").radio(:value => "Know-Nothing").set? ? "Know-Nothing" : retval
  retval
}

# Define a "set" for the control
party.add_set { |input|
  Parfait::browser.div(:id => "radio-example").radio(:value => input).set
}


########################################
# Define a Region to isolate a president
########################################
president = Parfait::Region.new(:name => "President")

# Add this region to the page
sample_page.add_region(president)








