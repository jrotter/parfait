require 'parfait/artifact'
require 'parfait/application'
require 'parfait/page'
require 'parfait/region'
require 'parfait/control'

# [cat]  something
# something else
#
#
# * Top level comment about Parfait

module Parfait

  # Global hash containing each Parfait::Page object indexed by page name (and alias)
  PAGES = Hash.new


  # Configure the logging routine to be used by Parfait for this thread.
  #
  # The routine you store here can be invoked by Parfait.log
  #
  # *Options*
  #
  # +&block+:: specifies the code block to be called whenever Parfait needs to invoke a logger.  This block should take a string followed by an optional hash as its parameters.
  #
  # *Example*
  #
  #   Parfait.set_logroutine { |string,opts|
  #     MyLogger::write(string,opts)
  #   }
  def Parfait.set_logroutine(&block)
    Thread.current[:parfait_logroutine] = block
  end 

 
  # Write to the Parfait log
  #
  # The log can be predefined by Parfait.set_logroutine
  #
  # *Options*
  #
  # +string+:: specifies the string to write to the Parfait log
  # +opts+:: specifies a hash containing parameters to the Parfait logging function
  #
  # *Example*
  #
  #   Parfait.log("Everything is fine - no bugs here.",:style => fatal_error)
  def Parfait.log(string,opts = {})
    return Thread.current[:parfait_logroutine].call(string,opts)
  end


  # Set the browser object (for the current thread) for Parfait to use
  #
  # *Options*
  #
  # +browser+:: specifies the browser to store
  #
  # *Example*
  #
  #   Parfait::set_browser(browser)
  #
  def Parfait.set_browser(browser)
    Thread.current[:parfait_browser] = browser
    Thread.current[:parfait_region] = browser
  end


  # Get the current browser object (for the current thread) from Parfait
  #
  # Note that inside regions, this may be a Selenium object and not the
  # selenium browser pointer (i.e. a subset of the page instead of the
  # whole page)
  #
  # *Options*
  #
  # none
  #
  # *Example*
  #
  #   Parfait::browser
  #
  def Parfait.browser()
    Thread.current[:parfait_region]
  end


  # Store a Watir object as a filtered browser to be used by controls called within a Region
  #
  # *Options*
  #
  # none
  #
  # *Example*
  #
  #   user_region = Parfait::Region.new(:name => "User")
  #   user_region.add_filter { |username|
  #     user_list = Parfait::browser.div(:id => "users")
  #     users = user_list.lis
  #     users.each do |li|
  #       if li.text == username
  #         Parfait::filter_browser li
  #         break
  #       end
  #     end
  #   }
  #
  def Parfait.filter_browser(object)()
    Thread.current[:parfait_region] = object
  end


end
