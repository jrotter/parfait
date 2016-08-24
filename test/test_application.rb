require 'minitest/autorun'
require 'test_helper'

class ApplicationTest < Minitest::Test

  def test_application_initialize_no_browser
    myapp = Parfait::Application.new(:name => "a")
    assert myapp.is_a? Parfait::Application
    myapp.set_browser(nil)
    assert myapp.is_a? Parfait::Application
  end

  def test_application_initialize_bad_browser
    n = "not a browser"
    assert_raises(RuntimeError) { 
      myapp = Parfait::Application.new(:name => "a",:browser => n)
    }
    myapp = Parfait::Application.new(:name => "a")
    assert_raises(RuntimeError) { 
      myapp.set_browser(n)
    }
  end

  def test_application_initialize_no_name
    # No name
    b = Watir::Browser.new
    assert_raises(RuntimeError) { 
      myapp = Parfait::Application.new(:browser => b)
    }
  end

  def test_application_find
    assert Parfait::Application.find("App One") == nil
    assert Parfait::Application.find("App Two") == nil
    assert Parfait::Application.find("App Three") == nil

    app1 = Parfait::Application.new(:name => "App One")
    assert Parfait::Application.find("App One") == app1
    assert Parfait::Application.find("App Two") == nil
    assert Parfait::Application.find("App Three") == nil

    app2 = Parfait::Application.new(:name => "App Two")
    assert Parfait::Application.find("App One") == app1
    assert Parfait::Application.find("App Two") == app2
    assert Parfait::Application.find("App Three") == nil

    app3 = Parfait::Application.new(:name => "App Three")
    assert Parfait::Application.find("App One") == app1
    assert Parfait::Application.find("App Two") == app2
    assert Parfait::Application.find("App Three") == app3
  end

  def test_application_initialize_browser_method
    b = Watir::Browser.new
    myapp = Parfait::Application.new(:name => "a", :browser => b)
    assert myapp.browser == b
    Thread.current[:parfait_browser] = nil
    assert_raises(RuntimeError) { myapp.browser }
    myapp = Parfait::Application.new(:name => "a", :browser => b)
    myapp.set_browser(b)
    assert myapp.browser == b
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

  def test_add_wrong_structure_to_application
    a = Parfait::Application.new(:name => "a")
    a2 = Parfait::Application.new(:name => "a2")
    p = Parfait::Page.new(:name => "p")
    r = Parfait::Region.new(:name => "r")
    c = Parfait::Control.new(:name => "c",:logtext => "l")
    assert a.add_page(p).is_a?(Parfait::Application)
    assert_raises(RuntimeError) { a.add_page(a2) }
    assert_raises(RuntimeError) { a.add_page(r) }
    assert_raises(RuntimeError) { a.add_page(c) }
  end

end
