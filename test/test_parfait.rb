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


  def test_parfait_generic_directives_input
    Parfait::set_logroutine { |string| } # no need to log anything
    @val = nil
    c1 = Parfait::Control.new(:name => "c1",:logtext => "control one")
    c1.add_set { |value| @val = value }
    c1.add_get { @val }
    c1.set "cat"
    assert c1.get == "cat"
    assert c1.retrieve == "cat"
    assert c1.confirm "cat"
    c1.verify "cat"
    assert_raises(RuntimeError) { c1.verify "tiger" }
    assert @val == "cat"

    c1.update "dog"
    assert c1.get == "dog"
    assert c1.retrieve == "dog"
    assert c1.confirm "dog"
    c1.verify "dog"
    assert_raises(RuntimeError) { c1.verify "dingo" }
    assert @val == "dog"
  end
 
  def test_parfait_custom_directives_input
    Parfait::set_logroutine { |string| } # no need to log anything
    @val = nil
    c1 = Parfait::Control.new(:name => "c1",:logtext => "control one")
    c1.add_update { |value| "chicken" }
    c1.add_retrieve { "duck" }
    c1.add_verify { |value| "goose" }
    c1.add_confirm { |value| "moose" }
    c1.add_set { |value| @val = value }
    c1.add_get { @val }
    c1.set "cat"
    assert c1.get == "cat"
    assert c1.update("something") == "chicken"
    assert c1.update("anything") == "chicken"
    assert c1.retrieve == "duck"
    assert c1.verify("something") == "goose"
    assert c1.verify("anything") == "goose"
    assert c1.confirm("something") == "moose"
    assert c1.confirm("anything") == "moose"
    assert @val == "cat"
  end
 
  def test_parfait_generic_directives_noninput
    Parfait::set_logroutine { |string| } # no need to log anything
    @val = nil
    c1 = Parfait::Control.new(:name => "c1",:logtext => "control one")
    c1.add_goto { "eureka" }
    assert c1.goto == "eureka"
    assert c1.navigate == "eureka"
  end
 
  def test_parfait_custom_directives_noninput
    Parfait::set_logroutine { |string| } # no need to log anything
    @val = nil
    c1 = Parfait::Control.new(:name => "c1",:logtext => "control one")
    c1.add_navigate { "squirrel" }
    c1.add_goto { "chipmonk" }
    assert c1.navigate == "squirrel"
    assert c1.goto == "chipmonk"
  end
 
 
end
