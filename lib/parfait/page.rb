module Parfait

  class Page

    attr_reader :name,
      :aliases
  
    # Create a Parfait page
    #
    # *Options*
    #
    # +name+:: specifies the name of the page
    # +aliases+:: specifies an array of aliases for the page
    #
    # *Example*
    #
    #   Parfait::Page.new(
    #     :name => "Prescription New", 
    #     :aliases => ["New Prescription", "New Rx", "Rx New"]
    #   )
    #
    def initialize(opts = {})
      o = {
        :name => nil,
        :aliases => []
      }.merge(opts)

      @name = o[:name]
      raise "Parfait::Page requires a name to be defined" unless @name
      raise "Parfait::Page requires name to be a string" unless @name.is_a?(String)

      @aliases = o[:aliases]
      if @aliases
        raise "Parfait::Page requires aliases to be an array" unless @aliases.is_a?(Array)
        @aliases.each do |my_alias|
          raise "Parfait::Page requires each alias in the array to be a string" unless my_alias.is_a?(String)
        end
      end
      
      @controls = Hash.new
      @regions = Hash.new
      @page_test = nil
    end

  
    # Add a Region to the current Page
    #
    # *Options*
    #
    # +region+:: specifies the Region object to be added
    #
    # *Example*
    #
    #   myregion = Parfait::Region.new(
    #     :name => "User List"
    #   )
    #   page.add_region(myregion)
    #
    def add_region(region)

      if region
        if region.is_a?(Parfait::Region)
          @regions[region.name] = region
          if region.aliases
            region.aliases.each do |my_alias|
              @regions[my_alias] = region
            end
          end
        else
          raise "Region must be a Parfait::Region when being added to a Page"
        end
      else
        raise "Region must be specified when adding a Region to a Page"
      end
      self
    end

  
    # Retrieve a Region object by name or alias.
    #
    # Under the covers, if there is an existence directive defined for this
    # region, it will be run on the current browser to confirm that it is
    # indeed present.
    #
    # *Options*
    #
    # +name+:: specifies the name or alias of the region
    #
    # *Example*
    #
    #   myregion.region("User List" => username)
    #
    def region(opts = {})
      region = @regions[opts.first[0]] 
      if region
        # Apply the filter method
        region.filter(opts.first[1])

        return region
      else
        raise "Invalid region name requested: \"#{requested_name}\""
      end
    end
    

    # Add a Control to the current Page
    #
    # *Options*
    #
    # +control+:: specifies the Control object to be added
    #
    # *Example*
    #
    #   page = Parfait::Page.new(
    #     :name => "Prescription New", 
    #     :aliases => ["New Prescription", "New Rx", "Rx New"]
    #   )
    #   control = Parfait::Control.new(
    #     :name => "Prescriber Name",
    #     :text => "prescriber full name"
    #   )
    #   page.add_control(control)
    #
    def add_control(control)

      if control
        if control.is_a?(Parfait::Control)
          @controls[control.name] = control
          if control.aliases
            control.aliases.each do |my_alias|
              @controls[my_alias] = control
            end
          end
        else
          raise "Control must be a Parfait::Control when being adding to a Page"
        end
      else
        raise "Control must be specified when adding a Control to an Page"
      end
      self
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
    def add_page_test(&block)
      @page_test = block
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
    def page_test(&block)
      @page_test.call()
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
    def add_navigation(&block)
      @navigate_method = block
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
    def navigate(opts = {})
      @navigate_method.call(opts)
    end

  
    # Retrieve a Control object by name or alias.
    #
    # Under the covers, if there is an existence directive defined for this
    # control, it will be run on the current browser to confirm that it is
    # indeed present.
    #
    # *Options*
    #
    # +name+:: specifies the name or alias of the control
    #
    # *Example*
    #
    #   mypage.control("User ID")
    def control(requested_name)
      control = @controls[requested_name] 
      if control
        # Confirm that the requested control is present

        return control
      else
        raise "Invalid control name requested: \"#{requested_name}\""
      end
    end
    
  end

end
