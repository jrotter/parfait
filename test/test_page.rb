require 'minitest/autorun'
require 'test_helper'

class PageTest < Minitest::Test

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

  def test_add_page_to_application_via_page_object
    p = Parfait::Page.new(:name => "my page")
    p.add_to_application("Hello")
    assert_raises(RuntimeError) { p.add_to_application(nil) }
    assert_raises(RuntimeError) { p.add_to_application(12) }
    a = Parfait::Application.find("Hello")
    assert a.page("my page") == p

    b = Parfait::Application.new(:name => "Goodbye")
    q = Parfait::Page.new(:name => "my page")
    q.add_to_application(b)
    assert_raises(RuntimeError) { q.add_to_application(nil) }
    assert_raises(RuntimeError) { q.add_to_application(12) }
    assert b.page("my page") == q
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

  def test_add_region_to_page_via_page
    p = Parfait::Page.new(:name => "page")
    r = Parfait::Region.new(:name => "region")
    r.add_filter { |a,b| a }
    assert p.add_region(r).is_a?(Parfait::Page)
    assert p.region("region" => "chicken") == r
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
   
end
