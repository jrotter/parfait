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
    # +option+:: specifies something
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def add_check(&block)
      @check_method = block
      add_generic_present() unless @present_method 
    end


    # Check if the ParfaitArtifact is present
    #
    # *Options*
    #
    # This method does not take any parameters.
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def check(opts = {})
      @check_method.call(opts)
    end


    # Define the present directive for a given ParfaitArtifact
    #
    # *Options*
    #
    # +option+:: specifies something
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def add_present(&block)
      @present_method = block
    end


    # Is the ParfaitArtifact present?
    #
    # *Options*
    #
    # This method does not take any parameters.
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def present(opts = {})
      @present_method.call(opts)
    end


    # Method description
    #
    # Depends on check
    #
    # *Options*
    #
    # +option+:: specifies something
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def add_generic_present()
      add_present { |opts|
        check(opts)
      }
    end


    # Is the present method defined for this Artifact?
    #
    # Depends on check
    #
    # *Options*
    #
    # This method takes no parameters
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def is_present_defined?()
      if @present_method
        return true
      else
        return false
      end
    end

  end
end

