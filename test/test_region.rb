require 'minitest/autorun'
require 'test_helper'

class RegionTest < Minitest::Test

  def test_add_region_to_page_via_self
    p = Parfait::Page.new(:name => "page")
    r = Parfait::Region.new(:name => "region")
    r.add_filter { |a,b| a }
    assert r.add_to_page(p).is_a?(Parfait::Region)
    assert p.region("region" => "rooster") == r
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

  def test_add_region_to_region_via_existing_object
    parent = Parfait::Region.new(:name => "parent")
    child = Parfait::Region.new(:name => "child")
    assert parent.add_region(child).is_a?(Parfait::Region)

    child = Parfait::Region.new(:name => "child",:aliases => ["x","y"])
    assert parent.add_region(child).is_a?(Parfait::Region)
  end

  def test_add_region_to_parent_via_constructor
    # Parent is a Page
    p = Parfait::Page.new(:name => "page")
    assert (r = Parfait::Region.new(:name => "region",:parent => p)).is_a?(Parfait::Region)
    r.add_filter { |a,b| a }
    assert p.region("region" => "rooster") == r

    # Parent is an Region
    parent = Parfait::Region.new(:name => "parent")
    assert (child = Parfait::Region.new(:name => "child",:parent => parent)).is_a?(Parfait::Region)
    child.add_filter { |a,b| a }
    assert parent.region("child" => "rooster") == child

    # Parent is an Application (error expected)
    a = Parfait::Application.new(:name => "app")
    assert_raises(RuntimeError) {
      r = Parfait::Region.new(:name => "region",:parent => a)
    }

    # Parent is a Control (error expected)
    c = Parfait::Control.new(:name => "c",:logtext => "c")
    assert_raises(RuntimeError) {
      r = Parfait::Region.new(:name => "region",:parent => c)
    }

    # Parent is Gibberish (error expected)
    assert_raises(RuntimeError) {
      r = Parfait::Region.new(:name => "region",:parent => "not an object")
    }
  end

  def test_add_region_to_region_via_new_object
    parent = Parfait::Region.new(:name => "parent")
    parent.add_filter { |a,b| a }
    child = Parfait::Region.new(:name => "child")
    child.add_filter { |a,b| a }
    assert child.add_to_region(parent).is_a?(Parfait::Region)
    assert parent.region("child" => "seagull") == child
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

end
