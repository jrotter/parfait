require 'minitest/autorun'
require 'webtester'

module Watir
  class Browser
    def initialize
    end
  end
end

module WebTester
  class Page
    attr_reader :name
  end
end


class WebTesterTest < Minitest::Test

  #
  #WebTester.configure(opts = {})
  #WebTester.browser()
  #
  def test_no_browser
    Thread.current[:webtester_browser] = nil
    assert_raises(RuntimeError) { WebTester.browser }
    assert_raises(RuntimeError) { WebTester.configure }
    assert_raises(RuntimeError) { WebTester.browser }
  end

  def test_configure_browser_bad
    b = "baloney"
    assert_raises(RuntimeError) { WebTester.configure(:browser => b) }
    assert_raises(RuntimeError) { 
      Thread.current[:webtester_browser] = nil 
      WebTester.browser 
    }
  end

  def test_configure_browser_good
    b = Watir::Browser.new
    assert WebTester.configure(:browser => b)
    returned_browser = nil
    assert returned_browser = WebTester.browser
    assert returned_browser.is_a?(Watir::Browser)
  end

  #
  #WebTester.add_page(opts = {})
  #WebTester.get_page(name)
  #
  def test_add_page_no_alias
    WebTester.add_page(:name => "My Page")
    page = WebTester.get_page("My Page")
    assert(page.is_a?(WebTester::Page),"get_page did not return the page we added")
    assert(page.name == "My Page","get_page did not return the correct page name")
  end

  def test_add_page_alias
    WebTester.add_page(:name => "My Page",:aliases => ["A Page","B Page","C Page"])
    a_page = WebTester.get_page("A Page")
    assert(a_page.is_a?(WebTester::Page),"get_page did not return the page we added")
    assert(a_page.name == "My Page","get_page did not return the correct page name")
    b_page = WebTester.get_page("B Page")
    assert(b_page.is_a?(WebTester::Page),"get_page did not return the page we added")
    assert(b_page.name == "My Page","get_page did not return the correct page name")
    c_page = WebTester.get_page("C Page")
    assert(c_page.is_a?(WebTester::Page),"get_page did not return the page we added")
    assert(c_page.name == "My Page","get_page did not return the correct page name")
    my_page = WebTester.get_page("My Page")
    assert(my_page.is_a?(WebTester::Page),"get_page did not return the page we added")
    assert(my_page.name == "My Page","get_page did not return the correct page name")
  end

  def test_get_invalid_page
    assert_raises(RuntimeError) do
      page = WebTester.get_page("This Page Does Not Exist")
    end
  end

  #
  #WebTester.set(opts = {})
  #WebTester.update(opts = {})
  #WebTester.navigate(opts = {})
  #WebTester.verify(opts = {})
  #WebTester.retrieve(opts = {})
  #WebTester.confirm(opts = {})
  #
  def test_webtester_verb_nopage
    assert_raises(RuntimeError) { page = WebTester.set(:foo => "Hello") }
    assert_raises(RuntimeError) { page = WebTester.update(:foo => "Hello") }
    assert_raises(RuntimeError) { page = WebTester.navigate(:to => "Other Page") }
    assert_raises(RuntimeError) { page = WebTester.verify(:foo => "Hello") }
    assert_raises(RuntimeError) { page = WebTester.retrieve(:data => :foo) }
    assert_raises(RuntimeError) { page = WebTester.confirm(:foo => "Hello") }
  end
 
  def test_webtester_verb_badpage
    assert_raises(RuntimeError) { page = WebTester.set(:onpage => "Page Does Not Exist", :foo => "Hello") }
    assert_raises(RuntimeError) { page = WebTester.update(:onpage => "Page Does Not Exist", :foo => "Hello") }
    assert_raises(RuntimeError) { page = WebTester.navigate(:onpage => "Page Does Not Exist", :to => "Other Page") }
    assert_raises(RuntimeError) { page = WebTester.verify(:onpage => "Page Does Not Exist", :foo => "Hello") }
    assert_raises(RuntimeError) { page = WebTester.retrieve(:onpage => "Page Does Not Exist", :data => :foo) }
    assert_raises(RuntimeError) { page = WebTester.confirm(:onpage => "Page Does Not Exist", :foo => "Hello") }
  end
 
  def test_webtester_verb_invalid_control
    WebTester.add_page(:name => "Invalid Control Page")
    assert_raises(RuntimeError) { page = WebTester.set(:onpage => "Invalid Control Page", :foo => "Hello") }
    assert_raises(RuntimeError) { page = WebTester.update(:onpage => "Invalid Control Page", :foo => "Hello") }
    assert_raises(RuntimeError) { page = WebTester.verify(:onpage => "Invalid Control Page", :foo => "Hello") }
    assert_raises(RuntimeError) { page = WebTester.retrieve(:onpage => "Invalid Control Page", :data => :foo) }
    assert_raises(RuntimeError) { page = WebTester.confirm(:onpage => "Invalid Control Page", :foo => "Hello") }
  end
 
  def test_webtester_navigate_requirements
    #Right now, I use "All Pages" as the page when no page is specified.  I should
    #  formalize this a bit more.  Either I can default all verbs to use some default
    #  space when onpage is not specified or I should use something other than the string
    #  "All Pages".  Just clean it up a bit.
    #assert_raises(RuntimeError) do
    #  page = WebTester.navigate(:onpage => "Invalid Control Page", :to => "Some Other Page")
    #end
    #assert_raises(RuntimeError) do
    #  page = WebTester.navigate(:onpage => "Invalid Control Page", :to => "Some Other Page")
    #end
  end
 
  def test_control_set_generic
    WebTester.set_logroutine { |logtext| nil } #don't log during test suite
    page = WebTester.add_page(:name => "page_001")
    control = page.add_control(:label => :control_001, :text => "control_001")
    @myvalue = nil
    control.add_get { |opts| @myvalue }
    control.add_set { |value| @myvalue = value }

    assert_equal control.get(), nil
    assert_equal control.retrieve(), nil

    # Add data via control.set
    @testval = "test_control_set_generic"
    assert_equal  control.set(@testval), @testval
    assert_equal  control.get(:data => :control_001), @testval
    assert_equal  control.retrieve(:data => :control_001), @testval
    assert        control.confirm(:control_001 => @testval)
    assert_equal  control.confirm(:control_001 => "wrong"), false
    assert        control.verify(:control_001 => @testval)
    assert_raises (RuntimeError) { control.verify(:control_001 => "wrong") }
    assert_equal  WebTester.retrieve(:onpage => "page_001", :data => :control_001), @testval
    assert        WebTester.confirm(:onpage => "page_001", :control_001 => @testval)
    assert_equal  WebTester.confirm(:onpage => "page_001", :control_001 => "wrong"), false
    assert        WebTester.verify(:onpage => "page_001", :control_001 => @testval)
    assert_raises (RuntimeError) { WebTester.verify(:onpage => "page_001", :control_001 => "wrong") }
  end
 
  def test_control_update_generic
    WebTester.set_logroutine { |logtext| nil } #don't log during test suite
    page = WebTester.add_page(:name => "page_002")
    control = page.add_control(:label => :control_002, :text => "control_002")
    @myvalue = nil
    control.add_get { |opts| @myvalue }
    control.add_set { |value| @myvalue = value }

    assert_equal control.get(), nil
    assert_equal control.retrieve(), nil

    # Add data via control.update
    @testval = "test_control_update_generic"
    assert_equal  control.update(:control_002 => @testval), @testval
    assert_equal  control.get(:data => :control_002), @testval
    assert_equal  control.retrieve(:data => :control_002), @testval
    assert        control.confirm(:control_002 => @testval)
    assert_equal  control.confirm(:control_002 => "wrong"), false
    assert        control.verify(:control_002 => @testval)
    assert_raises (RuntimeError) { control.verify(:control_002 => "wrong") }
    assert_equal  WebTester.retrieve(:onpage => "page_002", :data => :control_002), @testval
    assert        WebTester.confirm(:onpage => "page_002", :control_002 => @testval)
    assert_equal  WebTester.confirm(:onpage => "page_002", :control_002 => "wrong"), false
    assert        WebTester.verify(:onpage => "page_002", :control_002 => @testval)
    assert_raises (RuntimeError) { WebTester.verify(:onpage => "page_002", :control_002 => "wrong") }

  end
 
  def test_webtester_update_generic
    WebTester.set_logroutine { |logtext| nil } #don't log during test suite
    page = WebTester.add_page(:name => "page_003")
    control = page.add_control(:label => :control_003, :text => "control_003")
    @myvalue = nil
    control.add_get { |opts| @myvalue }
    control.add_set { |value| @myvalue = value }

    assert_equal control.get(), nil
    assert_equal control.retrieve(), nil

    # Add data via WebTester.update
    @testval = "test_webtester_update_generic"
    assert_equal  WebTester.update(:onpage => "page_003", :control_003 => @testval), @testval
    assert_equal  control.get(:data => :control_003), @testval
    assert_equal  control.retrieve(:data => :control_003), @testval
    assert        control.confirm(:control_003 => @testval)
    assert_equal  control.confirm(:control_003 => "wrong"), false
    assert        control.verify(:control_003 => @testval)
    assert_raises (RuntimeError) { control.verify(:control_003 => "wrong") }
    assert_equal  WebTester.retrieve(:onpage => "page_003", :data => :control_003), @testval
    assert        WebTester.confirm(:onpage => "page_003", :control_003 => @testval)
    assert_equal  WebTester.confirm(:onpage => "page_003", :control_003 => "wrong"), false
    assert        WebTester.verify(:onpage => "page_003", :control_003 => @testval)
    assert_raises (RuntimeError) { WebTester.verify(:onpage => "page_003", :control_003 => "wrong") }

  end
 
end
