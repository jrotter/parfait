module Parfait

  class Control
  
    attr_reader :name,
      :aliases
  
    # Create a new control object
    #
    # *Options*
    #
    # +name+:: the name used to identify this control
    # +logtext+:: the text to be used when referring to this control in logs
    # +aliases+:: specifies an array of aliases for the page
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
        :aliases => []
      }.merge(opts)
      @name = o[:name]
      @aliases = o[:aliases]
      @logtext = o[:logtext]
      @set_method = nil
      @get_method = nil
      @update_method = nil
      @retrieve_method = nil
      @verify_method = nil
      @confirm_method = nil

      if @name
        unless @name.is_a?(String)
          raise "Name must be a String when adding a control"
        end
      else
        raise "Name must be specified when adding a control"
      end
      if @logtext
        unless @logtext.is_a?(String)
          raise "Text must be a String when adding a control"
        end
      else
        raise "Text must be specified when adding a control" 
      end
      if @aliases
        unless @aliases.is_a?(Array)
          raise "Parfait::Control requires aliases to be an array"
        end
        @aliases.each do |my_alias|
          raise "Parfait::Control requires each alias in the array to be a string" unless my_alias.is_a?(String)
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
    def get(opts = {})
      return @get_method.call(opts)
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
    def set(opts = {})
      @set_method.call(opts)
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
    def update(opts = {})
      @update_method.call(opts)
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
    def confirm(opts = {})
      return @confirm_method.call(opts)
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
    def verify(opts = {})
      @verify_method.call(opts)
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
  
      add_generic_retrieve()
      add_generic_confirm()
      add_generic_verify()
      if @set_method != nil
        add_generic_update
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
        add_generic_update()
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
      add_update { |opts|
        # $$$ Add a check here to ensure that opts[@label] matches something
        new_value = opts[@label]
        found_value = retrieve(opts)
        if new_value == found_value
          capital_text = @logtext
          capital_text[0] = capital_text[0].capitalize
          Parfait.log("#{capital_text} is already set to \"#{new_value}\"")
        else
          Parfait.log("Entering #{@logtext}: \"#{new_value}\" (was \"#{found_value}\")")
          set(new_value)
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
      add_verify { |opts|
        # $$$ Add a check here to ensure that opts[@label] matches something
        value = opts[@label]
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
      add_confirm { |opts|
        retval = false
        # $$$ Add a check here to ensure that opts[@label] matches something
        value = opts[@label]
        found_value = retrieve()
        if value == found_value
          retval = true
        end
        retval
      }        
    end
  
  end

end
