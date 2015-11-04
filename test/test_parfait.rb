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

  def test_add_control_to_page
    p = Parfait::Page.new(:name => "page")
    c = Parfait::Control.new(:name => "c",:logtext => "d")
    assert p.add_control(c).is_a?(Parfait::Page)

    c = Parfait::Control.new(:name => "c",:logtext => "d",:aliases => ["x","y"])
    assert p.add_control(c).is_a?(Parfait::Page)
  end

  def test_get_control_from_page
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

  def test_add_control_to_region
    r = Parfait::Region.new(:name => "region")
    c = Parfait::Control.new(:name => "c",:logtext => "d")
    assert r.add_control(c).is_a?(Parfait::Region)

    c = Parfait::Control.new(:name => "c",:logtext => "d",:aliases => ["x","y"])
    assert r.add_control(c).is_a?(Parfait::Region)
  end

  def test_get_control_from_region
    r = Parfait::Region.new(:name => "region")
    c1 = Parfait::Control.new(:name => "c1",:logtext => "control one")
    c2 = Parfait::Control.new(:name => "c2",:logtext => "control two",:aliases => ["cdeux","cdos","c++"])
    assert r.add_control(c1).add_control(c2).is_a?(Parfait::Region)
    assert r.control("c1") == c1
    assert r.control("c2") == c2
    assert r.control("cdeux") == c2
    assert r.control("cdos") == c2
    assert r.control("c++") == c2
    assert_raises(RuntimeError) { r.control("c3") }
  end

  def test_add_region_to_region
    parent = Parfait::Region.new(:name => "parent")
    child = Parfait::Region.new(:name => "child")
    assert parent.add_region(child).is_a?(Parfait::Region)

    child = Parfait::Region.new(:name => "child",:aliases => ["x","y"])
    assert parent.add_region(child).is_a?(Parfait::Region)
  end

  def test_get_region_from_region
    parent = Parfait::Region.new(:name => "parent")
    child1 = Parfait::Region.new(:name => "child1")
    child1.add_filter { |a,b| a }
    child2 = Parfait::Region.new(:name => "child2",:aliases => ["x","y","z"])
    child2.add_filter { |a,b| a }
    assert parent.add_region(child1).add_region(child2).is_a?(Parfait::Region)
    assert parent.region("child1" => "foo") == child1
    assert parent.region("child2" => "foo") == child2
    assert parent.region("x" => "foo") == child2
    assert parent.region("y" => "foo") == child2
    assert parent.region("z" => "foo") == child2
    assert_raises(RuntimeError) { parent.region("notfound" => "foo") }
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

  def test_add_wrong_structure_to_page
    a = Parfait::Application.new(:name => "a")
    p = Parfait::Page.new(:name => "p")
    p2 = Parfait::Page.new(:name => "p2")
    r = Parfait::Region.new(:name => "r")
    c = Parfait::Control.new(:name => "c",:logtext => "l")
    assert p.add_control(c).is_a?(Parfait::Page)
    assert_raises(RuntimeError) { p.add_control(a) }
    assert_raises(RuntimeError) { p.add_control(p2) }
    assert_raises(RuntimeError) { p.add_control(r) }
    assert p.add_region(r).is_a?(Parfait::Page)
    assert_raises(RuntimeError) { p.add_region(a) }
    assert_raises(RuntimeError) { p.add_region(p2) }
    assert_raises(RuntimeError) { p.add_region(c) }
  end

  def test_add_wrong_structure_to_region
    a = Parfait::Application.new(:name => "a")
    p = Parfait::Page.new(:name => "p")
    r = Parfait::Region.new(:name => "r")
    r2 = Parfait::Region.new(:name => "r2")
    c = Parfait::Control.new(:name => "c",:logtext => "l")
    assert r.add_control(c).is_a?(Parfait::Region)
    assert_raises(RuntimeError) { r.add_control(a) }
    assert_raises(RuntimeError) { r.add_control(p) }
    assert_raises(RuntimeError) { r.add_control(r2) }
    assert r.add_region(r2).is_a?(Parfait::Region)
    assert_raises(RuntimeError) { r.add_region(a) }
    assert_raises(RuntimeError) { r.add_region(p) }
    assert_raises(RuntimeError) { r.add_region(c) }
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
    c1 = Parfait::Control.new(:name => "c1",:logtext => "control one")
    c1.add_goto { "eureka" }
    assert c1.goto == "eureka"
    assert c1.navigate == "eureka"
  end
 
  def test_parfait_custom_directives_noninput
    Parfait::set_logroutine { |string| } # no need to log anything
    c1 = Parfait::Control.new(:name => "c1",:logtext => "control one")
    c1.add_navigate { "squirrel" }
    c1.add_goto { "chipmonk" }
    assert c1.navigate == "squirrel"
    assert c1.goto == "chipmonk"
  end
 
  def test_parfait_end_to_end_1
    Parfait::set_logroutine { |string| } # no need to log anything
    b = Watir::Browser.new

    app = Parfait::Application.new(:name => "Application")
    app.set_browser(b)

    page = Parfait::Page.new(:name => "Page")
    app.add_page(page)

    control = Parfait::Control.new(:name => "Control",:logtext => "control")
    page.add_control(control)
    control.add_get { @value }
    control.add_set { |input| @value = input }

    Thread.current[:parfait_region] = ""
    Thread.current[:parfait_browser] = "armadillo"
    app.page("Page").control("Control").update "hello"
    assert Thread.current[:parfait_region] == Thread.current[:parfait_browser]

    Thread.current[:parfait_region] = ""
    Thread.current[:parfait_browser] = "bat"
    assert app.page("Page").control("Control").retrieve == "hello"
    assert Thread.current[:parfait_region] == Thread.current[:parfait_browser]

    Thread.current[:parfait_region] = ""
    Thread.current[:parfait_browser] = "capybara"
    app.page("Page").control("Control").verify "hello"
    assert Thread.current[:parfait_region] == Thread.current[:parfait_browser]

    Thread.current[:parfait_region] = ""
    Thread.current[:parfait_browser] = "dingo"
    assert app.page("Page").control("Control").confirm "hello"
    assert Thread.current[:parfait_region] == Thread.current[:parfait_browser]
  end

  def test_parfait_end_to_end_2
    Parfait::set_logroutine { |string| } # no need to log anything
    b = Watir::Browser.new

    app = Parfait::Application.new(:name => "Application")
    app.set_browser(b)

    page = Parfait::Page.new(:name => "Page")
    app.add_page(page)

    region = Parfait::Region.new(:name => "Region")
    page.add_region(region)
    region.add_filter { |value| Thread.current[:parfait_region] += "#{value}" }

    control = Parfait::Control.new(:name => "Control",:logtext => "control")
    region.add_control(control)
    control.add_get { @value }
    control.add_set { |input| @value = input }

    Thread.current[:parfait_region] = ""
    Thread.current[:parfait_browser] = "armadillo"
    app.page("Page").region("Region" => " poop").control("Control").update "hello"
    assert Thread.current[:parfait_region] == "armadillo poop"

    Thread.current[:parfait_region] = ""
    Thread.current[:parfait_browser] = "bat"
    assert app.page("Page").region("Region" => " poop").control("Control").retrieve == "hello"
    assert Thread.current[:parfait_region] == "bat poop"

    Thread.current[:parfait_region] = ""
    Thread.current[:parfait_browser] = "capybara"
    app.page("Page").region("Region" => " poop").control("Control").verify "hello"
    assert Thread.current[:parfait_region] == "capybara poop"

    Thread.current[:parfait_region] = ""
    Thread.current[:parfait_browser] = "dingo"
    assert app.page("Page").region("Region" => " poop").control("Control").confirm "hello"
    assert Thread.current[:parfait_region] == "dingo poop"
  end
   
  def test_parfait_end_to_end_3
    Parfait::set_logroutine { |string| } # no need to log anything
    b = Watir::Browser.new

    app = Parfait::Application.new(:name => "Application")
    app.set_browser(b)
    page = Parfait::Page.new(:name => "Page")
    app.add_page(page)

    region1 = Parfait::Region.new(:name => "Region 1")
    page.add_region(region1)
    region1.add_filter { |value| Thread.current[:parfait_region] += "#{value}" }

    region2 = Parfait::Region.new(:name => "Region 2")
    region1.add_region(region2)
    region2.add_filter { |value| Thread.current[:parfait_region] += "#{value}" }

    control = Parfait::Control.new(:name => "Control",:logtext => "control")
    region2.add_control(control)
    control.add_get { @value }
    control.add_set { |input| @value = input }

    Thread.current[:parfait_region] = ""
    Thread.current[:parfait_browser] = "fox"
    app.page("Page").region("Region 1" => " trot").region("Region 2" => " zero").control("Control").update "hello"
    assert Thread.current[:parfait_region] == "fox trot zero"

    Thread.current[:parfait_region] = ""
    Thread.current[:parfait_browser] = "gecko"
    assert app.page("Page").region("Region 1" => " insurance").region("Region 2" => " salesman").control("Control").retrieve == "hello"
    assert Thread.current[:parfait_region] == "gecko insurance salesman"

    Thread.current[:parfait_region] = ""
    Thread.current[:parfait_browser] = "hyena"
    app.page("Page").region("Region 1" => " laughing").region("Region 2" => " stock").control("Control").verify "hello"
    assert Thread.current[:parfait_region] == "hyena laughing stock"

    Thread.current[:parfait_region] = ""
    Thread.current[:parfait_browser] = "ibis"
    assert app.page("Page").region("Region 1" => " football").region("Region 2" => " stinks").control("Control").confirm "hello"
    assert Thread.current[:parfait_region] == "ibis football stinks"
  end
   
   
end
