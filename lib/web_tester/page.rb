module WebTester

  class Page
  
    # Method description
    #
    # *Options*
    #
    # +option+:: specifies something
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def initialize(name)
      @name = name
      @controls = Hash.new
      @page_test = nil
      @navigate_method = nil
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
    def add_control(opts = {})
      o = {
        :label => :notspecified,
        :text => :notspecified,
        :set_method => :notspecified,
        :get_method => :notspecified
      }.merge(opts)
      label = o[:label]
      text = o[:text]
      set_method = o[:set_method]
      get_method = o[:get_method]

      if label == :notspecified
        raise "Label must be specified when adding a control"
      end
      if text == :notspecified
        raise "Text must be specified when adding a control"
      end
    
      my_control = WebTester::Control.new(
        :label => label,
        :text => text,
        :page_name => @name,
        :set_method => set_method,
        :get_method => get_method)
      
      @controls[label] = my_control
      return my_control
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

  
    # Method description
    #
    # *Options*
    #
    # +option+:: specifies something
    #
    # *Example*
    #
    #   $$$ Need an example $$$
    def get_control(label)
      return @controls[label]
    end
    
  end

end
