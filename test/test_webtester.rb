require 'test/unit'
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


class WebTesterTest < Test::Unit::TestCase

  #
  #WebTester.configure(opts = {})
  #WebTester.browser()
  #
  def test_no_browser
    Thread.current[:webtester_browser] = nil
    assert_raise(RuntimeError) do
      WebTester.browser
    end
    assert_raise(RuntimeError) do
      WebTester.configure
    end
    assert_raise(RuntimeError) do
      WebTester.browser
    end
  end

  def test_configure_browser_bad
    b = "baloney"
    assert_raise(RuntimeError) do
      WebTester.configure(:browser => b)
    end
    assert_raise(RuntimeError) do
      WebTester.browser
    end
  end

  def test_configure_browser_good
    b = Watir::Browser.new
    assert_nothing_thrown "Valid browser assignment threw an exception" do
      WebTester.configure(:browser => b)
    end
    returned_browser = nil
    assert_nothing_thrown "Valid browser assignment threw an exception" do
      returned_browser = WebTester.browser
    end
    assert(returned_browser.is_a?(Watir::Browser))
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
    assert_raise(RuntimeError) do
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
  #WebTester.generic_update(opts = {})
  #
  def test_webtester_verb_nopage
    assert_raise(RuntimeError) do
      page = WebTester.set(:foo => "Hello")
    end
    assert_raise(RuntimeError) do
      page = WebTester.update(:foo => "Hello")
    end
    assert_raise(RuntimeError) do
      page = WebTester.navigate(:to => "Some Other Page")
    end
    assert_raise(RuntimeError) do
      page = WebTester.verify(:foo => "Hello")
    end
    assert_raise(RuntimeError) do
      page = WebTester.retrieve(:data => :foo)
    end
    assert_raise(RuntimeError) do
      page = WebTester.confirm(:foo => "Hello")
    end
    assert_raise(RuntimeError) do
      page = WebTester.generic_update(:foo => "Hello")
    end
  end
 
  def test_webtester_verb_badpage
    assert_raise(RuntimeError) do
      page = WebTester.set(:onpage => "Page Does Not Exist", :foo => "Hello")
    end
    assert_raise(RuntimeError) do
      page = WebTester.update(:onpage => "Page Does Not Exist", :foo => "Hello")
    end
    assert_raise(RuntimeError) do
      page = WebTester.navigate(:onpage => "Page Does Not Exist", :to => "Some Other Page")
    end
    assert_raise(RuntimeError) do
      page = WebTester.verify(:onpage => "Page Does Not Exist", :foo => "Hello")
    end
    assert_raise(RuntimeError) do
      page = WebTester.retrieve(:onpage => "Page Does Not Exist", :data => :foo)
    end
    assert_raise(RuntimeError) do
      page = WebTester.confirm(:onpage => "Page Does Not Exist", :foo => "Hello")
    end
    assert_raise(RuntimeError) do
      page = WebTester.generic_update(:onpage => "Page Does Not Exist", :foo => "Hello")
    end
  end
 
  def test_webtester_verb_invalid_control
    WebTester.add_page(:name => "Invalid Control Page")
    assert_raise(RuntimeError) do
      page = WebTester.set(:onpage => "Invalid Control Page", :foo => "Hello")
    end
    assert_raise(RuntimeError) do
      page = WebTester.update(:onpage => "Invalid Control Page", :foo => "Hello")
    end
    assert_raise(RuntimeError) do
      page = WebTester.verify(:onpage => "Invalid Control Page", :foo => "Hello")
    end
    assert_raise(RuntimeError) do
      page = WebTester.retrieve(:onpage => "Invalid Control Page", :data => :foo)
    end
    assert_raise(RuntimeError) do
      page = WebTester.confirm(:onpage => "Invalid Control Page", :foo => "Hello")
    end
    assert_raise(RuntimeError) do
      page = WebTester.generic_update(:onpage => "Invalid Control Page", :foo => "Hello")
    end
  end
 
  def test_webtester_navigate_requirements
    #Right now, I use "All Pages" as the page when no page is specified.  I should
    #  formalize this a bit more.  Either I can default all verbs to use some default
    #  space when onpage is not specified or I should use something other than the string
    #  "All Pages".  Just clean it up a bit.
    #assert_raise(RuntimeError) do
    #  page = WebTester.navigate(:onpage => "Invalid Control Page", :to => "Some Other Page")
    #end
    #assert_raise(RuntimeError) do
    #  page = WebTester.navigate(:onpage => "Invalid Control Page", :to => "Some Other Page")
    #end
  end
 
end
