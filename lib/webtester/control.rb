module WebTester

  class Control
  
    def initialize(opts = {})
    o = {
        :label => :notspecified,
        :text => :notspecified,
        :page_name => :notspecified,
        :set_method => :notspecified,
        :get_method => :notspecified
      }.merge(opts)
      @label = o[:label]
      @text = o[:text]
      @set_method = nil
      @get_method = nil
      @update_method = nil
      @retrieve_method = nil
      @verify_method = nil
      @confirm_method = nil
    end

    def get(opts = {})
      return @get_method.call(opts)
    end
  
    def set(opts = {})
      @set_method.call(opts)
    end
  
    def retrieve(opts = {})
      return @retrieve_method.call(opts)
    end
  
    def update(opts = {})
      @update_method.call(opts)
    end
  
    def confirm(opts = {})
      return @confirm_method.call(opts)
    end
  
    def verify(opts = {})
      @verify_method.call(opts)
    end
 
 
    def add_get(&block)
      @get_method = block
  
      add_generic_retrieve()
      add_generic_confirm()
      add_generic_verify()
      if @set_method != nil
        add_generic_update
      end 
    end
  
    def add_set(&block)
      @set_method = block
    
      if @get_method != nil
        add_generic_update()
      end 
    end
  
    def add_update(&block)
      @update_method = block
    end

    def add_retrieve(&block)
      @retrieve_method = block
    end

    def add_verify(&block)
      @verify_method = block
    end

    def add_confirm(&block)
      @confirm_method = block
    end
 
 
    def add_generic_update()
      add_update { |opts|
        new_value = opts[@label]
        found_value = retrieve_old(opts)
        if new_value == found_value
          capital_text = @text
          capital_text[0] = capital_text[0].capitalize
          Logger::write("#{capital_text} is already set to \"#{new_value}\"")
        else
          Logger::write("Entering #{@text}: \"#{new_value}\" (was \"#{found_value}\")")
          set(new_value)
        end
      }
    end
  
    def add_generic_retrieve()
      add_retrieve { |opts|
        get(opts)
      }
    end
  
    def add_generic_verify()
      add_verify { |opts|
        value = opts[@label]
        found_value = retrieve_old()
        if value == found_value
          Logger::write("Verified #{@text} to be \"#{value}\"")
        else
          puts Atom::stripped_page()
          raise TestcaseException, "Expected #{@text} to be \"#{value}\", but found \"#{found_value}\" instead"
        end
      }    
    end
  
    def add_generic_confirm()
      add_verify { |opts|
        retval = false
        value = opts[@label]
        found_value = retrieve_old()
        if value == found_value
          retval = true
        end
        retval
      }        
    end
  
  end

end
