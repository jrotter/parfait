module Parfait

  class Region
  
    attr_reader :name,
      :aliases
  
    # Create a new region object
    #
    # Regions use filters to reduce the scope of HTML that their child
    # elements (Controls or other Regions) need to consider.  This allows
    # for easier management of repeated controls on a page.
    #
    # For instance, assume the Region's parent is a Page and that
    # page contains a list of users, each with an "Edit" link next to them.  
    # Defining a Region would allow any child controls to look
    # specifically at a single user, by userid, perhaps.  Then a child 
    # control can be created to select "Edit" for the chosen userid.
    #
    # *Options*
    #
    # +name+:: the name used to identify this region
    # +aliases+:: specifies an array of aliases for the region
    #
    # *Example*
    #
    #   # Define the application
    #   mybrowser = Watir::Browser.new()
    #   myapp = Parfait::Application.new(
    #     :name => "Blog",
    #     :browser => mybrowser
    #   )
    #  
    #   # Define the page
    #   mypage = Parfait::Page.new(
    #     :name => "User List"
    #   )
    #   mybrowser.add_page(mypage)
    #   
    #   # Define the region
    #   myregion = Parfait::Region.new(
    #     :name => "User"
    #   )
    #   
    def initialize(opts = {})
    o = {
        :name => nil,
        :aliases => []
      }.merge(opts)
      @name = o[:name]
      @aliases = o[:aliases]
      @controls = Hash.new
      @pages = Hash.new

      if @name
        unless @name.is_a?(String)
          raise "Name must be a String when adding a region"
        end
      else
        raise "Name must be specified when adding a region"
      end
      if @aliases
        unless @aliases.is_a?(Array)
          raise "Parfait::Region requires aliases to be an array"
        end
        @aliases.each do |my_alias|
          raise "Parfait::Region requires each alias in the array to be a string" unless my_alias.is_a?(String)
        end
      end
    end


    # Set the filter for this Region to use.
    #
    # When a child of this Region is invoked, the Region will use this 
    # filter to zoom in on a subset of the parent element's HTML in order
    # to reduce the scope of HTML that the child needs to consider.
    #
    # The defined filter should alter the +Thread.current[:parfait_region]+
    # value.
    #
    # *Options*
    #
    # +block+:: specifies the block of code that will reduce the scope of HTML by updating +Thread.current[:parfait_region]+.  The block should take a single parameter indicating data unique to the filtered region.  For example, in a list of users, the block parameter could be a user ID.
    # 
    # *Example*
    #
    #   # Define the application
    #   mybrowser = Watir::Browser.new()
    #   myapp = Parfait::Application.new(
    #     :name => "Blog",
    #     :browser => mybrowser
    #   )
    #  
    #   # Define the page
    #   mypage = Parfait::Page.new(
    #     :name => "User List"
    #   )
    #   mybrowser.add_page(mypage)
    #   
    #   # Define the region
    #   myregion = Parfait::Region.new(
    #     :name => "User"
    #   )
    #
    #   # Set the filter for this region to look specifically at user ID
    #   myregion.add_filter { |userid|
    #     Thread.current[:parfait_region] =  Thread.current[:parfait_region].div(:id => "userlist").div(:text => /#{userid}/)
    #   }
    #   mypage.add_region(myregion)
    #   
    #   # Use the Region to focus on the entry for User "jrotter"
    #   myapp.page("User List").region("User" => "jrotter")
    #   
    def add_filter(&block)
      @filter_method = block
    end

  
    # Add a Region to the current Region
    #
    # *Options*
    #
    # +region+:: specifies the Region object to be added
    #
    # *Example*
    #
    #   region1 = Parfait::Region.new(
    #     :name => "User List"
    #   )
    #   page.add_region(region1)
    #   region2 = Parfait::Region.new(
    #     :name => "User Roles"
    #   )
    #   region1.add_region(region2)
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
          raise "Region must be a Parfait::Region when being added to another Region"
        end
      else
        raise "Region must be specified when adding a Region to another Region"
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
        region.filter_method.call(first[1])

        return region
      else
        raise "Invalid region name requested: \"#{requested_name}\""
      end
    end
    

    # Add a Control to the current Region
    #
    # *Options*
    #
    # +control+:: specifies the Control object to be added
    #
    # *Example*
    #
    #   region = Parfait::Region.new(
    #     :name => "Prescription List" 
    #   )
    #   control = Parfait::Control.new(
    #     :name => "Edit Prescription"
    #   )
    #   region.add_control(control)
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
          raise "Control must be a Parfait::Control when being adding to a Region"
        end
      else
        raise "Control must be specified when adding a Control to an Region"
      end
      self
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
    #   myregion.control("User ID")
    #
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




