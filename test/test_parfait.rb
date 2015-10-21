require 'minitest/autorun'
require 'parfait'

module Watir
  class Browser
    def initialize
    end
  end
end

module Parfait
  class Page
    attr_reader :name
  end
end


class ParfaitTest < Minitest::Test

  def test_application_creation_no_browser
    myapp = Parfait::Application.new(:name => "a")
    assert myapp.is_a? Parfait::Application
    myapp.set_browser(nil)
    assert myapp.is_a? Parfait::Application
  end

  def test_application_creation_bad_browser
    n = "not a browser"
    assert_raises(RuntimeError) { 
      myapp = Parfait::Application.new(:name => "a",:browser => n)
    }
    myapp = Parfait::Application.new(:name => "a")
    assert_raises(RuntimeError) { 
      myapp.set_browser(n)
    }
  end

  def test_application_creation_no_name
    # No name
    b = Watir::Browser.new
    assert_raises(RuntimeError) { 
      myapp = Parfait::Application.new(:browser => b)
    }
  end

  def test_application_creation_browser_method
    b = Watir::Browser.new
    myapp = Parfait::Application.new(:name => "a", :browser => b)
    assert myapp.browser == b
    Thread.current[:parfait_browser] = nil
    assert_raises(RuntimeError) { myapp.browser }
    myapp = Parfait::Application.new(:name => "a", :browser => b)
    myapp.set_browser(b)
    assert myapp.browser == b
  end


  def test_page_creation_happy_path
    assert Parfait::Page.new(:name => "a").is_a?(Parfait::Page)
    assert Parfait::Page.new(:name => "a",:aliases => ["b","c"]).is_a?(Parfait::Page)
  end

  def test_page_creation_page_name_definition
    assert_raises(RuntimeError) { 
      Parfait::Page.new(:name => :not_a_string)
    }
    assert_raises(RuntimeError) { 
      Parfait::Page.new(:name => ["not","a","string"])
    }
  end

  def test_page_creation_page_alias_definition
    assert_raises(RuntimeError) { 
      Parfait::Page.new(:name => "a",:aliases => "Not an array")
    }
    assert_raises(RuntimeError) { 
      Parfait::Page.new(:name => "a",:aliases => [:not_a_string])
    }
    assert_raises(RuntimeError) { 
      Parfait::Page.new(:name => "a",:aliases =>["b","c",:not_a_string])
    }
  end

  def test_add_page_to_application_happy_path_no_alias
    a = Parfait::Application.new(:name => "app")
    p = Parfait::Page.new(:name => "my page")
    a.add_page(p)
    assert a.page("my page").is_a?(Parfait::Page)
    assert a.page("my page").name == "my page"
  end

  def test_add_page_to_application_happy_path_alias
    a = Parfait::Application.new(:name => "app")
    p = Parfait::Page.new(:name => "my page", :aliases => ["x","y","z"])
    a.add_page(p)
    assert a.page("my page").is_a?(Parfait::Page)
    assert a.page("my page").name == "my page"
    assert a.page("x").name == "my page"
    assert a.page("y").name == "my page"
    assert a.page("z").name == "my page"
  end

  def test_add_page_to_application_bad_page_no_alias
    a = Parfait::Application.new(:name => "app")
    p = Parfait::Page.new(:name => "my page")
    a.add_page(p)
    assert_raises(RuntimeError) { 
      a.page("will not be found")
    }
  end

  def test_add_page_to_application_bad_page_aliases
    a = Parfait::Application.new(:name => "app")
    p = Parfait::Page.new(:name => "my page", :aliases => ["x","y","z"])
    a.add_page(p)
    assert_raises(RuntimeError) { 
      a.page("will not be found")
    }
  end

  def test_new_control_happy_path
    assert Parfait::Control.new(:name => "c",:logtext => "d").is_a?(Parfait::Control)
    assert Parfait::Control.new(:name => "c",:logtext => "d", :aliases => ["x","y"]).is_a?(Parfait::Control)
  end

  def test_new_control_validation_checks
    assert_raises(RuntimeError) { 
      Parfait::Control.new(:name => "c")
    }
    assert_raises(RuntimeError) { 
      Parfait::Control.new(:name => :not_a_string,:logtext => "d")
    }
    assert_raises(RuntimeError) { 
      Parfait::Control.new(:logtext => "d")
    }
    assert_raises(RuntimeError) { 
      Parfait::Control.new(:name => "c",:logtext => :not_a_string)
    }
    assert_raises(RuntimeError) {
      Parfait::Control.new(:name => "c",:logtext => "d", :aliases => "Not array")
    }
    assert_raises(RuntimeError) {
      Parfait::Control.new(:name => "c",:logtext => "d", :aliases => [:not_string])
    }
  end

  def test_add_control
    p = Parfait::Page.new(:name => "page")
    c = Parfait::Control.new(:name => "c",:logtext => "d")
    assert p.add_control(c).is_a?(Parfait::Page)

    c = Parfait::Control.new(:name => "c",:logtext => "d",:aliases => ["x","y"])
    assert p.add_control(c).is_a?(Parfait::Page)
  end

  def test_get_control
    p = Parfait::Page.new(:name => "page")
    c1 = Parfait::Control.new(:name => "c1",:logtext => "control one")
    c2 = Parfait::Control.new(:name => "c2",:logtext => "control two",:aliases => ["cdeux","cdos","c++"])
    assert p.add_control(c1).add_control(c2).is_a?(Parfait::Page)
    assert p.control("c1") == c1
    assert p.control("c2") == c2
    assert p.control("cdeux") == c2
    assert p.control("cdos") == c2
    assert p.control("c++") == c2
    assert_raises(RuntimeError) { p.control("c3") }
  end



  #
  #Parfait.set(opts = {})
  #Parfait.update(opts = {})
  #Parfait.navigate(opts = {})
  #Parfait.verify(opts = {})
  #Parfait.retrieve(opts = {})
  #Parfait.confirm(opts = {})
  #
  def test_parfait_verb_nopage
    #assert_raises(RuntimeError) { page = Parfait.set(:foo => "Hello") }
    #assert_raises(RuntimeError) { page = Parfait.update(:foo => "Hello") }
    #assert_raises(RuntimeError) { page = Parfait.navigate(:to => "Other Page") }
    #assert_raises(RuntimeError) { page = Parfait.verify(:foo => "Hello") }
    #assert_raises(RuntimeError) { page = Parfait.retrieve(:data => :foo) }
    #assert_raises(RuntimeError) { page = Parfait.confirm(:foo => "Hello") }
  end
 
  def test_parfait_verb_badpage
    #assert_raises(RuntimeError) { page = Parfait.set(:onpage => "Page Does Not Exist", :foo => "Hello") }
    #assert_raises(RuntimeError) { page = Parfait.update(:onpage => "Page Does Not Exist", :foo => "Hello") }
    #assert_raises(RuntimeError) { page = Parfait.navigate(:onpage => "Page Does Not Exist", :to => "Other Page") }
    #assert_raises(RuntimeError) { page = Parfait.verify(:onpage => "Page Does Not Exist", :foo => "Hello") }
    #assert_raises(RuntimeError) { page = Parfait.retrieve(:onpage => "Page Does Not Exist", :data => :foo) }
    #assert_raises(RuntimeError) { page = Parfait.confirm(:onpage => "Page Does Not Exist", :foo => "Hello") }
  end
 
  def test_parfait_verb_invalid_control
    #Parfait.add_page(:name => "Invalid Control Page")
    #assert_raises(RuntimeError) { page = Parfait.set(:onpage => "Invalid Control Page", :foo => "Hello") }
    #assert_raises(RuntimeError) { page = Parfait.update(:onpage => "Invalid Control Page", :foo => "Hello") }
    #assert_raises(RuntimeError) { page = Parfait.verify(:onpage => "Invalid Control Page", :foo => "Hello") }
    #assert_raises(RuntimeError) { page = Parfait.retrieve(:onpage => "Invalid Control Page", :data => :foo) }
    #assert_raises(RuntimeError) { page = Parfait.confirm(:onpage => "Invalid Control Page", :foo => "Hello") }
  end
 
  def test_parfait_navigate_requirements
    #Right now, I use "All Pages" as the page when no page is specified.  I should
    #  formalize this a bit more.  Either I can default all verbs to use some default
    #  space when onpage is not specified or I should use something other than the string
    #  "All Pages".  Just clean it up a bit.
    #assert_raises(RuntimeError) do
    #  page = Parfait.navigate(:onpage => "Invalid Control Page", :to => "Some Other Page")
    #end
    #assert_raises(RuntimeError) do
    #  page = Parfait.navigate(:onpage => "Invalid Control Page", :to => "Some Other Page")
    #end
  end
 
  def test_control_set_generic
    #Parfait.set_logroutine { |logtext| nil } #don't log during test suite
    #page = Parfait.add_page(:name => "page_001")
    #control = page.add_control(:label => :control_001, :text => "control_001")
    #@myvalue = nil
    #control.add_get { |opts| @myvalue }
    #control.add_set { |value| @myvalue = value }

    #assert_equal control.get(), nil
    #assert_equal control.retrieve(), nil
#
    # Add data via control.set
    #@testval = "test_control_set_generic"
    #assert_equal  control.set(@testval), @testval
    #assert_equal  control.get(:data => :control_001), @testval
    #assert_equal  control.retrieve(:data => :control_001), @testval
    #assert        control.confirm(:control_001 => @testval)
    #assert_equal  control.confirm(:control_001 => "wrong"), false
    #assert        control.verify(:control_001 => @testval)
    #assert_raises (RuntimeError) { control.verify(:control_001 => "wrong") }
    #assert_equal  Parfait.retrieve(:onpage => "page_001", :data => :control_001), @testval
    #assert        Parfait.confirm(:onpage => "page_001", :control_001 => @testval)
    #assert_equal  Parfait.confirm(:onpage => "page_001", :control_001 => "wrong"), false
    #assert        Parfait.verify(:onpage => "page_001", :control_001 => @testval)
    #assert_raises (RuntimeError) { Parfait.verify(:onpage => "page_001", :control_001 => "wrong") }
  end
 
  def test_control_update_generic
    #Parfait.set_logroutine { |logtext| nil } #don't log during test suite
    #page = Parfait.add_page(:name => "page_002")
    #control = page.add_control(:label => :control_002, :text => "control_002")
    #@myvalue = nil
    #control.add_get { |opts| @myvalue }
    #control.add_set { |value| @myvalue = value }

    #assert_equal control.get(), nil
    #assert_equal control.retrieve(), nil

    # Add data via control.update
    #@testval = "test_control_update_generic"
    #assert_equal  control.update(:control_002 => @testval), @testval
    #assert_equal  control.get(:data => :control_002), @testval
    #assert_equal  control.retrieve(:data => :control_002), @testval
    #assert        control.confirm(:control_002 => @testval)
    #assert_equal  control.confirm(:control_002 => "wrong"), false
    #assert        control.verify(:control_002 => @testval)
    #assert_raises (RuntimeError) { control.verify(:control_002 => "wrong") }
    #assert_equal  Parfait.retrieve(:onpage => "page_002", :data => :control_002), @testval
    #assert        Parfait.confirm(:onpage => "page_002", :control_002 => @testval)
    #assert_equal  Parfait.confirm(:onpage => "page_002", :control_002 => "wrong"), false
    #assert        Parfait.verify(:onpage => "page_002", :control_002 => @testval)
    #assert_raises (RuntimeError) { Parfait.verify(:onpage => "page_002", :control_002 => "wrong") }

  end
 
  def test_parfait_update_generic
    #Parfait.set_logroutine { |logtext| nil } #don't log during test suite
    #page = Parfait.add_page(:name => "page_003")
    #control = page.add_control(:label => :control_003, :text => "control_003")
    #@myvalue = nil
    #control.add_get { |opts| @myvalue }
    #control.add_set { |value| @myvalue = value }

    #assert_equal control.get(), nil
    #assert_equal control.retrieve(), nil

    ## Add data via Parfait.update
    #@testval = "test_parfait_update_generic"
    #assert_equal  Parfait.update(:onpage => "page_003", :control_003 => @testval), @testval
    #assert_equal  control.get(:data => :control_003), @testval
    #assert_equal  control.retrieve(:data => :control_003), @testval
    #assert        control.confirm(:control_003 => @testval)
    #assert_equal  control.confirm(:control_003 => "wrong"), false
    #assert        control.verify(:control_003 => @testval)
    #assert_raises (RuntimeError) { control.verify(:control_003 => "wrong") }
    #assert_equal  Parfait.retrieve(:onpage => "page_003", :data => :control_003), @testval
    #assert        Parfait.confirm(:onpage => "page_003", :control_003 => @testval)
    #assert_equal  Parfait.confirm(:onpage => "page_003", :control_003 => "wrong"), false
    #assert        Parfait.verify(:onpage => "page_003", :control_003 => @testval)
    #assert_raises (RuntimeError) { Parfait.verify(:onpage => "page_003", :control_003 => "wrong") }

  end
 
end
