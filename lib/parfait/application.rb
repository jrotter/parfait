module Parfait

  class Application
  
    # Define an application
    #
    # *Options*
    #
  # Takes a hash as input where the current options are:
    # +name+:: specifies the name of the application
    # - +:browser+ optionally specifies the browser object used in the current thread.  Storing this value will allow the browser object to be retrieved via +Parfait.browser+ invocation when defining +get+ and +set+ routines for controls.
    #
    # *Example*
    #
    #   mybrowser = Watir::Browser.new()
    #   Parfatit::Application.new(
    #     :name => "Facebook",
    #     :browser => mybrowser
    #   )
    #
    def initialize(opts = {})
      o = {
        :name => nil,
        :browser => nil
      }.merge(opts)

      @name = o[:name]
      raise "Application name must be specified" unless @name

      set_browser(o[:browser])

      @pages = Hash.new
    end

  
    # Set the browser object for the current thread.  
    #
    # *Options*
    #
    # none
    #
    # *Example*
    #
    #   b = Watir::browser.new
    #   myapplication.set_browser(b)
    # 
    def set_browser(browser)
      Thread.current[:parfait_browser] = browser 
      unless Thread.current[:parfait_browser] == nil or 
             Thread.current[:parfait_browser].is_a?(Watir::Browser)
        raise "Parfait browser parameter must be a Watir Browser object"
      end
    end

  
    # Get the browser object used by the current thread.  
    #
    # This will be particularly useful when defining directives for a Parfait::Control.
    #
    # *Options*
    #
    # none
    #
    # *Example*
    #
    #   mycontrol.add_get{ |opts|
    #     Parfait::browser.text_field(:id => "body").when_present.value
    #   }
    def browser()
      #If the browser is non-nil, then it passed validation in the configure method
      unless Thread.current[:parfait_browser]
        raise "Parfait: browser requested, but it is undefined"
      end
      Thread.current[:parfait_browser]
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
    def add_page(opts = {})
      o = {
        :label => :notspecified,
        :text => :notspecified,
      }.merge(opts)
      label = o[:label]
      text = o[:text]

      if label == :notspecified
        raise "Label must be specified when adding a control"
      end
      if text == :notspecified
        raise "Text must be specified when adding a control"
      end
    
      my_page = Parfait::Page.new(
        :label => label,
        :text => text,
        :page_name => @name)
      
      @pages[label] = my_page
      return my_page
    end


    # Retrieve a page object by label
    #
    # *Options*
    #
    # +name+:: specifies the label of the page
    #
    # *Example*
    #
    #   myapp.page(:user_new)
    def page(label)
      page_name = @pages[label] 
      if page_name
        return page_name
      else
        raise "Invalid page label requested: \"#{page_name}\""
      end
    end
      

  
  end

end
