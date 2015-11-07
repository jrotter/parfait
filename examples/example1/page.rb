# Define the Page
sample_page = Parfait::Page.new(:name => "Sample Page")

# Add the page to our application
$app.add_page(sample_page)


##################################################################
# Define the party selection control
##################################################################
party = Parfait::Control.new(:name => "Party", :logtext => "political party")

# Add our new control to the page
sample_page.add_control(party)

# Define a "get" for the control
party.add_get {
  retval = nil
  retval = Parfait::browser.div(:id => "radio-example").radio(:value => "Federalist").set? ? "Federalist" : retval
  retval = Parfait::browser.div(:id => "radio-example").radio(:value => "Republicrat").set? ? "Republicrat" : retval
  retval = Parfait::browser.div(:id => "radio-example").radio(:value => "Know-Nothing").set? ? "Know-Nothing" : retval
  retval
}

# Define a "set" for the control
party.add_set { |input|
  Parfait::browser.div(:id => "radio-example").radio(:value => input).set
}


##################################################################
# Define the "Set My Party" control
##################################################################
set_my_party = Parfait::Control.new(:name => "Set My Party", :logtext => "Set My Party button")

# Add our new control to the page
sample_page.add_control(set_my_party)

# Define a "goto" this control
set_my_party.add_goto {
  Parfait::browser.button(:value => "Set My Party").click
}


##################################################################
# Define a Region to isolate information for a single president
##################################################################
president_region = Parfait::Region.new(:name => "President")

# Add this region to the page
sample_page.add_region(president_region)

# Define a filter so that this region will allow focus on a single entry
president_region.add_filter { |president_name|
  table_rows = Parfait::browser.div(:id => "presidents").trs
  table_rows.each do |tr|
    if tr.text =~ /#{president_name}/
      Thread.current[:parfait_region] = tr
      break
    end
  end
  Thread.current[:parfait_region]
}


##################################################################
# Define the nickname control
##################################################################
nickname = Parfait::Control.new(:name => "Nickname", :logtext => "president nickname")

# Add our new control to the region
president_region.add_control(nickname)

# Define a "get" for the control
nickname.add_get {
  Parfait::browser.text_field.value
}

# Define a "set" for the control
nickname.add_set { |input|
  Parfait::browser.text_field.set input
}


##################################################################
# Define the "Update Nickname" control
##################################################################
update_nickname = Parfait::Control.new(:name => "Set My Party", :logtext => "Set My Party button")

# Add our new control to the President region
president_region.add_control(update_nickname)

# Define a "goto" this control
update_nickname.add_goto {
  Parfait::browser.button(:value => "Update").click
}


##################################################################
# Define the "Biography" control
##################################################################
biography = Parfait::Control.new(:name => "Biography", :logtext => "Biography link")

# Add our new control to the President region
president_region.add_control(biography)

# Define a "goto" this control
biography.add_goto {
  Parfait::browser.link(:text => "Biography").click
}



##################################################################
# Define the "Cabinet" control
##################################################################
cabinet = Parfait::Control.new(:name => "Cabinet", :logtext => "Cabinet link")

# Add our new control to the President region
president_region.add_control(cabinet)

# Define a "goto" this control
cabinet.add_goto {
  Parfait::browser.link(:text => "Cabinet").click
}






