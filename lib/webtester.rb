require 'watir-webdriver'
require 'webtester/page'
require 'webtester/control'

module WebTester

  PAGES = Hash.new
 
  def WebTester.configure(opts = {})
    o = {
      :browser => nil
    }.merge(opts)
 
    if o[:browser].is_a?(Watir::Browser)
      Thread.current[:webtester_browser] = o[:browser]
    else
      raise "WebTester browser parameter must be a Watir Browser object"
    end
  end
  

  def WebTester.browser()
    #If the browser is non-nil, then it passed validation in the configure method
    unless Thread.current[:webtester_browser]
      raise "WebTester: browser requested, but it is undefined"
    end
    Thread.current[:webtester_browser]
  end

  
  def WebTester.add_page(opts = {})
    o = {
      :name => :notspecified,
      :aliases => :notspecified
    }.merge(opts)
    name = o[:name]
    aliases = o[:aliases]
    
    new_page = WebTester::Page.new(name)
      
    WebTester::PAGES[name] = new_page
    unless aliases == :notspecified
      aliases.each { |an_alias|
        WebTester::PAGES[an_alias] = new_page
      }  
    end
    
    return new_page
  end

  
  def WebTester.get_page(name)
    page_name = WebTester::PAGES[name] 
    if page_name
      return page_name
    else
      raise "WebTester::get_page called for invalid page name \"#{page_name}\""
    end
  end
      

  # WebTester.set is only intended to be invoked from page routines, not externally
  def WebTester.set(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "WebTester::set must be called with \":onpage\" specified."
    end

    # Find the specified control and invoke its set method
    action_taken = false
    page = WebTester::get_page(o[:onpage])
    opts.each { |label,value|
      control = page.get_control(label)
      unless control == nil
        control.set(opts)
        action_taken = true
      end
    }
    unless action_taken
      raise "No valid control was passed to WebTester::set"
    end
  end
  
  
  def WebTester.retrieve(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "WebTester::retrieve must be called with \":onpage\" specified."
    end

    # Find the specified control and invoke its retrieve method
    action_taken = false
    page = WebTester::get_page(o[:onpage])
    opts.each { |label,value|
      if label == :data
        control = page.get_control(value)
        unless control == nil
          return control.retrieve(opts)
          action_taken = true
        end
      end
    }
    unless action_taken
      raise "No valid control was passed to WebTester::retrieve"
    end  
  end

  
  def WebTester.update(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "WebTester::update must be called with \":onpage\" specified."
    end

    # Find the specified control and invoke its update method
    action_taken = false
    page = WebTester::get_page(o[:onpage])
    opts.each { |label,value|
      control = page.get_control(label)
      unless control == nil
        control.update(opts)
        action_taken = true
      end
    }  
    unless action_taken
      raise "No valid control was passed to WebTester::update"
    end
  end
    
  
  def WebTester.verify(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "WebTester::verify must be called with \":onpage\" specified."
    end

    page = WebTester::get_page(o[:onpage])

    if opts.size == 1 #If no other parameters were passed, run the page test
      if page.page_test()
        Logger::write("Verified that browser is on page \"#{page.name}\"",:style => :h2)
      else
        raise  "WebTester expected browser to be on page #{page.name}, but it wasn\'t"
      end
    else
      # Find the specified control and invoke its verify method
      action_taken  = false
      opts.each { |label,value|
        control = page.get_control(label)
        unless control == nil
          control.verify(opts)
          action_taken = true
        end
      }
      unless action_taken
        raise "No valid control was passed to WebTester::verify"
      end  
    end  
  end

  
  def WebTester.confirm(opts = {})
    o = {
      :onpage => :nopage
    }.merge(opts)

    if o[:onpage] == :nopage
      raise "WebTester::confirm must be called with \":onpage\" specified."
    end

    page = WebTester::get_page(o[:onpage])

    if opts.size == 1 #If no other parameters were passed, run the page test
      return page.page_test()
    else
      # Find the specified control and invoke its confirm method
      action_taken = false
      opts.each { |label,value|
        control = page.get_control(label)
        unless control == nil
          control.confirm(opts)
          action_taken = true
        end
      }  
      unless action_taken
        raise "No valid control was passed to WebTester::confirm"
      end  
    end
  end


  def WebTester.navigate(opts = {})
    o = {
      :onpage => :nopage,
      :to => :nodestination
    }.merge(opts)
  
    if o[:to] == :nodestination
      raise "WebTester::navigate must be called with a destination (\":to\") specified."
    end

    if o[:onpage] == :nopage
      #Only a target was specified
      page = WebTester::get_page("All Pages")
    else
      page = WebTester::get_page(o[:onpage])
    end
    page.navigate(opts)
  end


end
