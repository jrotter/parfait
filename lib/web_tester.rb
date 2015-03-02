require 'watir-webdriver'
require 'web_tester/page'
require 'web_tester/control'

# [cat]  something
# something else
#
#
# * Top level comment about WebTester
module WebTester

  # Global hash containing each WebTester::Page object indexed by page name (and alias)
  PAGES = Hash.new


  # Configure WebTester settings
  #
  # *Options*
  #
  # Takes a hash as input where the current options are:
  # - +:browser+ specifies the browser object used in the current thread.  Storing this value will allow the browser object to be retrieved via +WebTester.browser+ invocation when defining +get+ and +set+ routines for controls.
  #
  # *Example*
  #
  #   mybrowser = Watir::Browser.new()
  #   WebTester.configure(:browser => mybrowser)
  def WebTester.configure(opts = {})
    o = {
      :browser => nil,
    }.merge(opts)
 
    if o[:browser].is_a?(Watir::Browser)
      Thread.current[:web_tester_browser] = o[:browser]
    else
      raise "WebTester browser parameter must be a Watir Browser object"
    end
  end


  # Get the browser object used by the current thread.  
  #
  # This will be particularly useful when defining directives for a WebTester::Control.
  #
  # *Options*
  #
  # none
  #
  # *Example*
  #
  #   mycontrol.add_get{ |opts|
  #     WebTester::browser.text_field(:id => "body").when_present.value
  #   }
  def WebTester.browser()
    #If the browser is non-nil, then it passed validation in the configure method
    unless Thread.current[:web_tester_browser]
      raise "WebTester: browser requested, but it is undefined"
    end
    Thread.current[:web_tester_browser]
  end

  
  # Configure the logging routine to be used by WebTester
  #
  # The routine you store here can be invoked by WebTester.log
  #
  # *Options*
  #
  # +&block+:: specifies the code block to be called whenever WebTester needs to invoke a logger.  This block should take a string followed by an optional hash as its parameters.
  #
  # *Example*
  #
  #   WebTester.set_logroutine { |string,opts|
  #     MyLogger::write(string,opts)
  #   }
  def WebTester.set_logroutine(&block)
    Thread.current[:web_tester_logroutine] = block
  end 

 
  # Write to the WebTester log
  #
  # The log can be predefined by WebTester.set_logroutine
  #
  # *Options*
  #
  # +string+:: specifies the string to write to the WebTester log
  # +opts+:: specifies a hash containing parameters to the WebTester logging function
  #
  # *Example*
  #
  #   WebTester.log("Everything is fine - no bugs here.",:style => fatal_error)
  def WebTester.log(string,opts = {})
    return Thread.current[:web_tester_logroutine].call(opts)
  end


  # Define a new page to WebTester
  #
  # *Options*
  #
  # +name+:: specifies the name of the page
  # +aliases+:: is an array of aliases for the page
  #
  # Note that the type of these values does not matter as long as they are used consistently throughout.  All examples provided with WebTester use strings.
  #
  # *Example*
  #
  #   edit_user = WebTester.add_page(
  #     :name => "Edit User",
  #     :alias => "New User", "User New", "User Edit"
  #   )
  def WebTester.add_page(opts = {})
    o = {
      :name => :notspecified,
      :aliases => :notspecified
    }.merge(opts)
    name = o[:name]
    aliases = o[:aliases]
    
    new_page = WebTester::Page.new(name)
      
    WebTester::PAGES[name] = new_page
    unless aliases == :notspecified
      aliases.each { |an_alias|
        WebTester::PAGES[an_alias] = new_page
      }  
    end
    
    return new_page
  end

  
  # Retrieve a page object by name or alias
  #
  # Intended for internal use only
  #
  # *Options*
  #
  # +name+:: specifies the name or alias of the page
  #
  # *Example*
  #
  #   WebTester.get_page("User New")
  def WebTester.get_page(name)
    page_name = WebTester::PAGES[name] 
    if page_name
      return page_name
    else
      raise "WebTester::get_page called for invalid page name \"#{page_name}\""
    end
  end
      

  # Set the value for a specified control on a specified page
  #
  # WebTester.set is only intended to be invoked from page directive routines, like retrieve, update, confirm, and verify.  It does not invoke the logger.
  #
  # *Options*
  #
  # WebTester.set takes a hash as a parameter with the +:onpage+ key specifying the page to be manipulated.  Users can utilize additional keys as they wish.  A simple invocation of WebTester.set might contain an additional key matching the label of a control on that page and providing a value to set in that control.
  #
  # *Example*
  #
  #   WebTester.set(:onpage => "Login", :username => "enrico_palazzo")
  def WebTester.set(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "WebTester::set must be called with \":onpage\" specified."
    end

    # Find the specified control and invoke its set method
    action_taken = false
    page = WebTester::get_page(o[:onpage])
    opts.each { |label,value|
      control = page.get_control(label)
      unless control == nil
        control.set(opts)
        action_taken = true
      end
    }
    unless action_taken
      raise "No valid control was passed to WebTester::set"
    end
  end
  
  
  # Retreive the value from a specified control on a specified page and return it
  #
  # *Options*
  #
  # The WebTester.retrieve directive takes a hash as a parameter with an +:onpage+ key specifying the current page.  The system-generated WebTester.retrieve directive will also take a +:data+ key specfying the control on that page from which data should be retrieved.  Users can override the system-generated directive and use any keys they wish. 
  #
  # The system-generated retrieve directive does not invoke the logger.
  #
  # *Example*
  #
  #   my_ssn = WebTester.retrieve(:onpage => "User Data", :data => :ssn)
  def WebTester.retrieve(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "WebTester::retrieve must be called with \":onpage\" specified."
    end

    # Find the specified control and invoke its retrieve method
    action_taken = false
    page = WebTester::get_page(o[:onpage])
    opts.each { |label,value|
      if label == :data
        control = page.get_control(value)
        unless control == nil
          return control.retrieve(opts)
          action_taken = true
        end
      end
    }
    unless action_taken
      raise "No valid control was passed to WebTester::retrieve"
    end  
  end

  
  # Update the value of a specified control on a specified page.  
  #
  # *Options*
  #
  # The WebTester.update directive takes a hash as a parameter with an +:onpage+ key specifying the current page.  The system-generated WebTester.update directive will also take a key matching the label of a control on that page and providing a value to set in that control.  Users can override the system-generated directive and use any keys they wish. 
  #
  # The system-generated update directive will log both the original value and the newly updated value.  It is assumed that users overriding the system-generated functionality will do the same.
  #
  # *Example*
  #
  #   WebTester.update(:onpage => "Configure Settings", :time_zone => "Eastern Time (US & Canada)")
  def WebTester.update(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "WebTester::update must be called with \":onpage\" specified."
    end

    # Find the specified control and invoke its update method
    retval = nil
    action_taken = false
    page = WebTester::get_page(o[:onpage])
    opts.each { |label,value|
      control = page.get_control(label)
      unless control == nil
        retval = control.update(opts)
        action_taken = true
      end
    }  
    unless action_taken
      raise "No valid control was passed to WebTester::update"
    end
    retval
  end
    
  
  # Verify the value of a specified control on a specified page, returning +true+ if it matches the provided value and raising an exception if it does not.
  #
  # *Options*
  #
  # The WebTester.verify directive takes a hash as a parameter with an +:onpage+ key specifying the current page.  The system-generated WebTester.verify directive will also take a key matching the label of a control on that page and providing a value against which to verify the current value of that control.  Users can override the system-generated directive and use any keys they wish. 
  #
  # The system-generated verify directive will log the successfully verified value.  It is assumed that users overriding the system-generated functionality will do the same.
  #
  # *Example*
  #
  #   WebTester.verify(:onpage => "Edit User", :social_security_number => "123-45-6789")
  def WebTester.verify(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "WebTester::verify must be called with \":onpage\" specified."
    end

    page = WebTester::get_page(o[:onpage])

    if opts.size == 1 #If no other parameters were passed, run the page test
      if page.page_test()
        WebTester.log("Verified that browser is on page \"#{page.name}\"",:style => :h2)
      else
        raise  "WebTester expected browser to be on page #{page.name}, but it wasn\'t"
      end
    else
      # Find the specified control and invoke its verify method
      action_taken  = false
      opts.each { |label,value|
        control = page.get_control(label)
        unless control == nil
          control.verify(opts)
          action_taken = true
        end
      }
      unless action_taken
        raise "No valid control was passed to WebTester::verify"
      end  
    end  
    true
  end

  
  # Confirm the value of a specified control on a specified page, returning +true+ if it matches the provided value and returning +false+ otherwise.
  #
  # *Options*
  #
  # The WebTester.confirm directive takes a hash as a parameter with an +:onpage+ key specifying the current page.  The system-generated WebTester.confirm directive will also take a key matching the label of a control on that page and providing a value against which to test the current value of that control.  Users can override the system-generated directive and use any keys they wish. 
  #
  # The system-generated confirm directive does not invoke the logger.
  #
  # *Example*
  #
  #   WebTester.confirm(:onpage => "Edit User", :gender => "female")
  def WebTester.confirm(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "WebTester::confirm must be called with \":onpage\" specified."
    end

    page = WebTester::get_page(o[:onpage])

    retval = false
    if opts.size == 1 #If no other parameters were passed, run the page test
      return page.page_test()
    else
      # Find the specified control and invoke its confirm method
      action_taken = false
      opts.each { |label,value|
        control = page.get_control(label)
        unless control == nil
          retval = control.confirm(opts)
          action_taken = true
        end
      }  
      if action_taken
        return retval
      else
        raise "No valid control was passed to WebTester::confirm"
      end  
    end
  end


  # Method description
  #
  # *Options*
  #
  # +option+:: specifies something
  #
  # *Example*
  #
  #   $$$ Need an example $$$
  def WebTester.navigate(opts = {})
    o = {
      :onpage => :nopage,
      :to => :nodestination
    }.merge(opts)
  
    if o[:to] == :nodestination
      raise "WebTester::navigate must be called with a destination (\":to\") specified."
    end

    if o[:onpage] == :nopage
      #Only a target was specified
      page = WebTester::get_page("All Pages")
    else
      page = WebTester::get_page(o[:onpage])
    end
    page.navigate(opts)
  end


end
