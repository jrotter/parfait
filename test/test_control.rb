require 'minitest/autorun'
require 'test_helper'

class ControlTest < Minitest::Test

  def setup
    Parfait::set_logroutine { |string| } # no need to log anything
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

  def test_add_control_to_parent_via_self
    # Parent is a Page
    p = Parfait::Page.new(:name => "page")
    c = Parfait::Control.new(:name => "c",:logtext => "d")
    assert c.add_to_page(p).is_a?(Parfait::Control)
    assert p.control("c") == c

    # Parent is a Region
    r = Parfait::Region.new(:name => "region")
    c = Parfait::Control.new(:name => "c",:logtext => "d")
    assert c.add_to_region(r).is_a?(Parfait::Control)
    assert r.control("c") == c
  end

  def test_add_control_to_parent_via_constructor
    # Parent is a Page
    p = Parfait::Page.new(:name => "page")
    assert (c = Parfait::Control.new(:name => "c",:logtext => "d",:parent => p)).is_a?(Parfait::Control)
    assert p.control("c") == c

    # Parent is a Region
    r = Parfait::Region.new(:name => "region")
    assert (c = Parfait::Control.new(:name => "c",:logtext => "d",:parent => r)).is_a?(Parfait::Control)
    assert r.control("c") == c

    # Parent is an Application (error expected)
    a = Parfait::Application.new(:name => "app")
    assert_raises(RuntimeError) {
      c = Parfait::Control.new(:name => "c",:logtext => "d",:parent => a)
    }

    # Parent is a Control (error expected)
    d = Parfait::Control.new(:name => "d",:logtext => "d")
    assert_raises(RuntimeError) {
      c = Parfait::Control.new(:name => "c",:logtext => "d",:parent => d)
    }

    # Parent is Gibberish (error expected)
    assert_raises(RuntimeError) {
      c = Parfait::Control.new(:name => "c",:logtext => "d",:parent => "not an object")
    }
  end

  def test_add_control_to_page_via_constructor
    p = Parfait::Page.new(:name => "page")
    c = Parfait::Control.new(:name => "c",:logtext => "d",:parent => p)
    assert p.control("c") == c
  end

  def test_parfait_generic_directives_input
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
    c1 = Parfait::Control.new(:name => "c1",:logtext => "control one")
    c1.add_goto { "eureka" }
    assert c1.goto == "eureka"
    assert c1.navigate == "eureka"
  end
 
  def test_parfait_custom_directives_noninput
    c1 = Parfait::Control.new(:name => "c1",:logtext => "control one")
    c1.add_navigate { "squirrel" }
    c1.add_goto { "chipmonk" }
    assert c1.navigate == "squirrel"
    assert c1.goto == "chipmonk"
  end
 
end
