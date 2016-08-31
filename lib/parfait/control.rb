module Parfait

  class Control < ParfaitArtifact
  
    attr_reader :name,
      :aliases
  
    # Create a new control object
    #
    # *Options*
    #
    # +name+:: the name used to identify this control
    # +logtext+:: the text to be used when referring to this control in logs
    # +aliases+:: specifies an array of aliases for the control
    # +parent+:: specifies the parent object (Region or Page) of this control
    #
    # *Example*
    #
    #   newcontrol = Parfait::Control.new(
    #     :name => "User ID",
    #     :logtext = "user ID"
    #   )
    def initialize(opts = {})
    o = {
        :name => nil,
        :logtext => nil,
        :aliases => [],
        :parent => nil
      }.merge(opts)
      @name = o[:name]
      @logtext = o[:logtext]
      @aliases = o[:aliases]
      @parent = o[:parent]

      @set_method = nil
      @get_method = nil
      @update_method = nil
      @retrieve_method = nil
      @verify_method = nil
      @confirm_method = nil
      @goto_method = nil
      @navigate_method = nil

      if @name
        unless @name.is_a?(String)
          raise "Name must be a String when adding a control"
        end
      else
        raise "Name must be specified when adding a control"
      end
      if @logtext
        unless @logtext.is_a?(String)
          raise "Logtext must be a String when adding a control"
        end
      else
        raise "Logtext must be specified when adding a control" 
      end
      if @aliases
        unless @aliases.is_a?(Array)
          raise "Parfait::Control requires aliases to be an array"
        end
        @aliases.each do |my_alias|
          raise "Parfait::Control requires each alias in the array to be a string" unless my_alias.is_a?(String)
        end
      end

      if @parent
        if @parent.is_a? Parfait::Page
          add_to_page(@parent)
        else
          if @parent.is_a? Parfait::Region
            add_to_region(@parent)
          else
            raise "Parent specified for Control \"#{@name}\", but parent object type unrecognized."
          end
        end
      end

      super
    end


    # Add this Control to a Page
    #
    # *Options*
    #
    # +page+:: specifies a Parfait::Page object to add this Control to
    #
    # *Example*
    #
    #   loginpage = Parfait::Page.new(
    #     :name => "Login Page"
    #   )
    #   newcontrol = Parfait::Control.new(
    #     :name => "User ID",
    #     :logtext = "user ID"
    #   )
    #   newcontrol.add_to_page(loginpage)
    #
    def add_to_page(page)

      if page
        case
        when page.is_a?(Parfait::Page)
          page.add_control(self)
        else
          raise "Input value must be a Page object when adding this Control to a Page"
        end
      else
        raise "Input value cannot be nil when adding this Control to a Page"
      end
      self
    end


    # Add this Control to a Region
    #
    # *Options*
    #
    # +region+:: specifies a Parfait::Region object to add this Control to
    #
    # *Example*
    #
    #   user = Parfait::Region.new(
    #     :name => "User"
    #   )
    #   newcontrol = Parfait::Control.new(
    #     :name => "Edit User",
    #     :logtext = "edit user link"
    #   )
    #   user.add_to_region(newcontrol)
    #
    def add_to_region(region)

      if region
        case
        when region.is_a?(Parfait::Region)
          region.add_control(self)
        else
          raise "Input value must be a Region object when adding this Control to a Region"
        end
      else
        raise "Input value cannot be nil when adding this Control to a Region"
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
    def verify_control_presence(directive_name)
      verify_presence "Cannot call \"#{directive_name}\" directive because presence check for control \"#{@name}\" failed"
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
    def get(opts = {})
      verify_control_presence("get")
      return @get_method.call(opts)
    end

  
    # Set the value for this control
    #
    # *Options*
    #
    # +value+:: specifies the value that this control will be set to
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def set(value,opts = {})
      verify_control_presence("set")
      @set_method.call(value,opts)
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
    def retrieve(opts = {})
      verify_control_presence("retrieve")
      return @retrieve_method.call(opts)
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
    def update(value,opts = {})
      verify_control_presence("update")
      @update_method.call(value,opts)
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
    def confirm(value,opts = {})
      verify_control_presence("confirm")
      return @confirm_method.call(value,opts)
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
    def verify(value,opts = {})
      verify_control_presence("verify")
      @verify_method.call(value,opts)
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
    def goto(opts = {})
      verify_control_presence("goto")
      return @goto_method.call(opts)
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
      verify_control_presence("navigate")
      return @navigate_method.call(opts)
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
    def add_get(&block)
      @get_method = block
  
      add_generic_retrieve() unless @retrieve_method
      add_generic_confirm() unless @confirm_method
      add_generic_verify() unless @verify_method
      if @set_method != nil
        add_generic_update unless @update_method
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
    def add_set(&block)
      @set_method = block
    
      if @get_method != nil
        add_generic_update() unless @update_method
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
    def add_update(&block)
      @update_method = block
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
    def add_retrieve(&block)
      @retrieve_method = block
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
    def add_verify(&block)
      @verify_method = block
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
    def add_confirm(&block)
      @confirm_method = block
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
    def add_goto(&block)
      @goto_method = block
      add_generic_navigate() unless @navigate_method
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
    def add_navigate(&block)
      @navigate_method = block
    end


    # Method description
    #
    # Depends on get, retrieve, set 
    #
    # *Options*
    #
    # +option+:: specifies something
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def add_generic_update()
      add_update { |value,opts|
        new_value = value
        found_value = retrieve()
        if new_value == found_value
          capital_text = @logtext
          capital_text[0] = capital_text[0].capitalize
          Parfait.log("#{capital_text} is already set to \"#{new_value}\"")
        else
          Parfait.log("Entering #{@logtext}: \"#{new_value}\" (was \"#{found_value}\")")
          set(new_value,opts)
        end
      }
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
    def add_generic_retrieve()
      add_retrieve { |opts|
        get(opts)
      }
    end

 
    # Method description
    #
    # Depends on get, retrieve 
    #
    # *Options*
    #
    # +option+:: specifies something
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def add_generic_verify()
      add_verify { |value,opts|
        found_value = retrieve()
        if value == found_value
          Parfait.log("Verified #{@logtext} to be \"#{value}\"")
        else
          raise "Expected #{@logtext} to be \"#{value}\", but found \"#{found_value}\" instead"
        end
        true
      }    
    end
 
 
    # Method description
    #
    # Depends on get, retrieve 
    #
    # *Options*
    #
    # +option+:: specifies something
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def add_generic_confirm()
      add_confirm { |value,opts|
        retval = false
        found_value = retrieve()
        if value == found_value
          retval = true
        end
        retval
      }        
    end
 
 
    # Method description
    #
    # Depends on goto
    #
    # *Options*
    #
    # +option+:: specifies something
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def add_generic_navigate()
      add_navigate { |opts|
        Parfait.log("Navigating to #{@logtext}")
        goto(opts)
      }
    end

  
  end

end
