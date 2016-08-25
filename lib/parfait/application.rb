module Parfait

  class Application < ParfaitArtifact
 
    # List of all defined applications 
    @@all = Hash.new

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
    #   Parfait::Application.new(
    #     :name => "Blog",
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
      @@all[@name] = self
      super
    end


    # Find an application object by name
    #
    # *Options*
    #
    # +name+:: specifies the name of the application to search for
    #
    # *Example*
    #
    #   blog_app = Parfait::Application.find("Blog App")
    #
    def self.find(name)
      @@all[name]
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

  
    # Add a page to this Application
    #
    # *Options*
    #
    # +page+:: specifies a Parfait::Page object
    #
    # *Example*
    #
    #   blog_posts = Parfait::Page.new(:name => "Blog Posts")
    #   blogapp.add_page(blog_posts)
    #
    def add_page(page)

      if page
        if page.is_a?(Parfait::Page)
          @pages[page.name] = page
          if page.aliases
            page.aliases.each do |my_alias|
              @pages[my_alias] = page
            end
          end
        else
          raise "Page must be a Parfait::Page when being adding to an application"
        end
      else
        raise "Page must be specified when adding a page to an application"
      end
      self
    end


    # Retrieve a page object by name or alias.
    #
    # Under the covers, if there is an existence directive defined for this
    # page, it will be run on the current browser to confirm that we are 
    # indeed on it.
    #
    # *Options*
    #
    # +name+:: specifies the name or alias of the page
    #
    # *Example*
    #
    #   myapp.page("Login Page")
    def page(requested_name)
      page = @pages[requested_name] 
      if page
        # Confirm that we are in the requested application
        verify_presence "Cannot navigate to page \"#{requested_name}\" because application presence check failed"

        # Pass the browser through to any subsequently called methods
        Thread.current[:parfait_region] = Thread.current[:parfait_browser]

        return page
      else
        raise "Invalid page name requested: \"#{requested_name}\""
      end
    end
      

  
  end

end
