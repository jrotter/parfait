require 'watir-webdriver'
require 'parfait/application'
require 'parfait/page'
require 'parfait/region'
require 'parfait/control'

# [cat]  something
# something else
#
#
# * Top level comment about Parfait
module Parfait

  # Global hash containing each Parfait::Page object indexed by page name (and alias)
  PAGES = Hash.new


  # Configure the logging routine to be used by Parfait
  #
  # The routine you store here can be invoked by Parfait.log
  #
  # *Options*
  #
  # +&block+:: specifies the code block to be called whenever Parfait needs to invoke a logger.  This block should take a string followed by an optional hash as its parameters.
  #
  # *Example*
  #
  #   Parfait.set_logroutine { |string,opts|
  #     MyLogger::write(string,opts)
  #   }
  def Parfait.set_logroutine(&block)
    Thread.current[:parfait_logroutine] = block
  end 

 
  # Write to the Parfait log
  #
  # The log can be predefined by Parfait.set_logroutine
  #
  # *Options*
  #
  # +string+:: specifies the string to write to the Parfait log
  # +opts+:: specifies a hash containing parameters to the Parfait logging function
  #
  # *Example*
  #
  #   Parfait.log("Everything is fine - no bugs here.",:style => fatal_error)
  def Parfait.log(string,opts = {})
    return Thread.current[:parfait_logroutine].call(string,opts)
  end


  # Define a new page to Parfait
  #
  # *Options*
  #
  # +name+:: specifies the name of the page
  # +aliases+:: is an array of aliases for the page
  #
  # Note that the type of these values does not matter as long as they are used consistently throughout.  All examples provided with Parfait use strings.
  #
  # *Example*
  #
  #   edit_user = Parfait.add_page(
  #     :name => "Edit User",
  #     :alias => "New User", "User New", "User Edit"
  #   )
  def Parfait.add_page(opts = {})
    o = {
      :name => :notspecified,
      :aliases => :notspecified
    }.merge(opts)
    name = o[:name]
    aliases = o[:aliases]
    
    new_page = Parfait::Page.new(name)
      
    Parfait::PAGES[name] = new_page
    unless aliases == :notspecified
      aliases.each { |an_alias|
        Parfait::PAGES[an_alias] = new_page
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
  #   Parfait.get_page("User New")
  def Parfait.get_page(name)
    page_name = Parfait::PAGES[name] 
    if page_name
      return page_name
    else
      raise "Parfait::get_page called for invalid page name \"#{page_name}\""
    end
  end
      

  # Set the value for a specified control on a specified page
  #
  # Parfait.set is only intended to be invoked from page directive routines, like retrieve, update, confirm, and verify.  It does not invoke the logger.
  #
  # *Options*
  #
  # Parfait.set takes a hash as a parameter with the +:onpage+ key specifying the page to be manipulated.  Users can utilize additional keys as they wish.  A simple invocation of Parfait.set might contain an additional key matching the label of a control on that page and providing a value to set in that control.
  #
  # *Example*
  #
  #   Parfait.set(:onpage => "Login", :username => "enrico_palazzo")
  def Parfait.set(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "Parfait::set must be called with \":onpage\" specified."
    end

    # Find the specified control and invoke its set method
    action_taken = false
    page = Parfait::get_page(o[:onpage])
    opts.each { |label,value|
      control = page.get_control(label)
      unless control == nil
        control.set(opts)
        action_taken = true
      end
    }
    unless action_taken
      raise "No valid control was passed to Parfait::set"
    end
  end
  
  
  # Retreive the value from a specified control on a specified page and return it
  #
  # *Options*
  #
  # The Parfait.retrieve directive takes a hash as a parameter with an +:onpage+ key specifying the current page.  The system-generated Parfait.retrieve directive will also take a +:data+ key specfying the control on that page from which data should be retrieved.  Users can override the system-generated directive and use any keys they wish. 
  #
  # The system-generated retrieve directive does not invoke the logger.
  #
  # *Example*
  #
  #   my_ssn = Parfait.retrieve(:onpage => "User Data", :data => :ssn)
  def Parfait.retrieve(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "Parfait::retrieve must be called with \":onpage\" specified."
    end

    # Find the specified control and invoke its retrieve method
    action_taken = false
    page = Parfait::get_page(o[:onpage])
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
      raise "No valid control was passed to Parfait::retrieve"
    end  
  end

  
  # Update the value of a specified control on a specified page.  
  #
  # *Options*
  #
  # The Parfait.update directive takes a hash as a parameter with an +:onpage+ key specifying the current page.  The system-generated Parfait.update directive will also take a key matching the label of a control on that page and providing a value to set in that control.  Users can override the system-generated directive and use any keys they wish. 
  #
  # The system-generated update directive will log both the original value and the newly updated value.  It is assumed that users overriding the system-generated functionality will do the same.
  #
  # *Example*
  #
  #   Parfait.update(:onpage => "Configure Settings", :time_zone => "Eastern Time (US & Canada)")
  def Parfait.update(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "Parfait::update must be called with \":onpage\" specified."
    end

    # Find the specified control and invoke its update method
    retval = nil
    action_taken = false
    page = Parfait::get_page(o[:onpage])
    opts.each { |label,value|
      control = page.get_control(label)
      unless control == nil
        retval = control.update(opts)
        action_taken = true
      end
    }  
    unless action_taken
      raise "No valid control was passed to Parfait::update"
    end
    retval
  end
    
  
  # Verify the value of a specified control on a specified page, returning +true+ if it matches the provided value and raising an exception if it does not.
  #
  # *Options*
  #
  # The Parfait.verify directive takes a hash as a parameter with an +:onpage+ key specifying the current page.  The system-generated Parfait.verify directive will also take a key matching the label of a control on that page and providing a value against which to verify the current value of that control.  Users can override the system-generated directive and use any keys they wish. 
  #
  # The system-generated verify directive will log the successfully verified value.  It is assumed that users overriding the system-generated functionality will do the same.
  #
  # *Example*
  #
  #   Parfait.verify(:onpage => "Edit User", :social_security_number => "123-45-6789")
  def Parfait.verify(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "Parfait::verify must be called with \":onpage\" specified."
    end

    page = Parfait::get_page(o[:onpage])

    if opts.size == 1 #If no other parameters were passed, run the page test
      if page.page_test()
        Parfait.log("Verified that browser is on page \"#{page.name}\"",:style => :h2)
      else
        raise  "Parfait expected browser to be on page #{page.name}, but it wasn\'t"
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
        raise "No valid control was passed to Parfait::verify"
      end  
    end  
    true
  end

  
  # Confirm the value of a specified control on a specified page, returning +true+ if it matches the provided value and returning +false+ otherwise.
  #
  # *Options*
  #
  # The Parfait.confirm directive takes a hash as a parameter with an +:onpage+ key specifying the current page.  The system-generated Parfait.confirm directive will also take a key matching the label of a control on that page and providing a value against which to test the current value of that control.  Users can override the system-generated directive and use any keys they wish. 
  #
  # The system-generated confirm directive does not invoke the logger.
  #
  # *Example*
  #
  #   Parfait.confirm(:onpage => "Edit User", :gender => "female")
  def Parfait.confirm(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "Parfait::confirm must be called with \":onpage\" specified."
    end

    page = Parfait::get_page(o[:onpage])

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
        raise "No valid control was passed to Parfait::confirm"
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
  def Parfait.navigate(opts = {})
    o = {
      :onpage => :nopage,
      :to => :nodestination
    }.merge(opts)
  
    if o[:to] == :nodestination
      raise "Parfait::navigate must be called with a destination (\":to\") specified."
    end

    if o[:onpage] == :nopage
      #Only a target was specified
      page = Parfait::get_page("All Pages")
    else
      page = Parfait::get_page(o[:onpage])
    end
    page.navigate(opts)
  end


  # Set the browser object (for the current thread) for Parfait to use
  #
  # *Options*
  #
  # +browser+:: specifies the browser to store
  #
  # *Example*
  #
  #   Parfait::set_browser(browser)
  #
  def Parfait.set_browser(browser)
    Thread.current[:parfait_browser] = browser
    Thread.current[:parfait_region] = browser
  end


  # Get the current browser object (for the current thread) from Parfait
  #
  # Note that inside regions, this may be a Selenium object and not the
  # selenium browser pointer (i.e. a subset of the page instead of the
  # whole page)
  #
  # *Options*
  #
  # none
  #
  # *Example*
  #
  #   Parfait::browser
  #
  def Parfait.browser()
    Thread.current[:parfait_region]
  end


end
