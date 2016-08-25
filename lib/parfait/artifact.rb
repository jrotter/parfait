module Parfait

  class ParfaitArtifact

    # Constructor for the ParfaitArtifact.
    #
    # *Options*
    #
    # This method does not take any parameters.
    #
    # No example provided because this method will not be called explicitly.
    # It will strictly be inherited by the Application, Page, Region, and
    # Control classes.
    #
    def initialize(opts = {})
      @check_method = nil
      @present_method = nil
    end


    # Define the presence check method for a given ParfaitArtifact
    #
    # *Options*
    #
    # +block+:: specifies the code block to be executed as the check method. This block should return true or false.
    #
    # *Example*
    #
    #   sample_page.add_check {
    #     Parfait::browser.h1(:text => "Parfait Example Page").present?
    #   }
    #
    def add_check(&block)
      @check_method = block
      add_generic_present() unless @present_method 
    end


    # Check if the ParfaitArtifact is present
    #
    # *Options*
    #
    # This method takes a hash of parameters, as defined by the +check+ code block
    #
    # *Example*
    #
    #   myapp.page("My Page").check
    #
    def check(opts = {})
      @check_method.call(opts)
    end


    # Define the present directive for a given ParfaitArtifact
    #
    # *Options*
    #
    # +block+:: specifies the code block to be executed as the present method. This block should return true or false.
    #
    # For consistency, it is recommended that the check method be defined with +add_check+, which will set up the present directive automatically.
    #
    # *Example*
    #
    #   sample_page.add_present {
    #     Parfait::browser.h1(:text => "Parfait Example Page").present?
    #   }
    #
    def add_present(&block)
      @present_method = block
    end


    # Is the ParfaitArtifact present?
    #
    # *Options*
    #
    # This method takes a hash of parameters, as defined by the +present+ code block
    #
    # *Example*
    #
    #   myapp.page("My Page").check
    #
    def present(opts = {})
      @present_method.call(opts)
    end


    # Define the secondary +present+ directive based on the user-defined primary +check+ directive
    #
    # *Options*
    #
    # None
    #
    # *Example*
    #
    #   No example provided - this will be called under the covers when a +check+ directive is defined
    #
    def add_generic_present()
      add_present { |opts|
        check(opts)
      }
    end


    # Is the present method defined for this Artifact?
    #
    # *Options*
    #
    # This method takes no parameters
    #
    # *Example*
    #
    #   myapp.page("My Page").is_present_defined?
    #
    def is_present_defined?()
      if @present_method
        return true
      else
        return false
      end
    end


    # Verify the presence of this Artifact
    #
    # Raises an exception with the specified check if this artifact is not present
    #
    # *Options*
    #
    # +error_string+:: specifies the string to display if the check fails
    #
    # *Example*
    #
    #   class Control
    #     def get(opts = {})
    #       verify_presence "Cannot call get directive because presence check for control \"#{@name}\" failed"
    #       return @get_method.call(opts)
    #     end
    #   end
    def verify_presence(error_string)
      if is_present_defined?
        unless present()
          raise error_string
        end
      end
    end

  end
end

