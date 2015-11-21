require 'minitest/autorun'
require 'test_helper'

class ArtifactTest < Minitest::Test

  def setup
    Parfait::set_logroutine { |string| } # no need to log anything
  end


  ##################################################
  #
  # Application
  #
  ##################################################
  def test_artifact_check_application_generic_present
    a = Parfait::Application.new(:name => "a")
    a.add_check {
      @test == "hello"
    }
    @test = nil
    assert a.check == false
    assert a.present == false
    @test = "goodbye"
    assert a.check == false
    assert a.present == false
    @test = "hello"
    assert a.check
    assert a.present
  end

  def test_artifact_check_application_custom_present_first
    a = Parfait::Application.new(:name => "a")
    a.add_present {
      @test == "goodbye"
    }
    a.add_check {
      @test == "hello"
    }
    @test = nil
    assert a.check == false
    assert a.present == false
    @test = "goodbye"
    assert a.check == false
    assert a.present
    @test = "hello"
    assert a.check
    assert a.present == false
  end

  def test_artifact_check_application_custom_present_last
    a = Parfait::Application.new(:name => "a")
    a.add_check {
      @test == "hello"
    }
    a.add_present {
      @test == "goodbye"
    }
    @test = nil
    assert a.check == false
    assert a.present == false
    @test = "goodbye"
    assert a.check == false
    assert a.present
    @test = "hello"
    assert a.check
    assert a.present == false
  end

  def test_artifact_application_present_defined
    a = Parfait::Application.new(:name => "a")
    assert a.is_present_defined? == false
    a.add_check {
      @test == "hello"
    }
    assert a.is_present_defined?
  end

  def test_artifact_application_presence_check_calling_page
    a = Parfait::Application.new(:name => "a")
    a.add_check {
      @test == "hello"
    }
    p = Parfait::Page.new(:name => "p")
    a.add_page(p)
    @test = "hello"
    a.page("p")
    @test = "goodbye"
    assert_raises(RuntimeError) { 
      a.page("p")
    }
  end


  ##################################################
  #
  # Page
  #
  ##################################################
  def test_artifact_check_page_generic_present
    p = Parfait::Page.new(:name => "p")
    p.add_check {
      @test == "hello"
    }
    @test = nil
    assert p.check == false
    assert p.present == false
    @test = "goodbye"
    assert p.check == false
    assert p.present == false
    @test = "hello"
    assert p.check
    assert p.present
  end

  def test_artifact_check_page_custom_present_first
    p = Parfait::Page.new(:name => "p")
    p.add_present {
      @test == "goodbye"
    }
    p.add_check {
      @test == "hello"
    }
    @test = nil
    assert p.check == false
    assert p.present == false
    @test = "goodbye"
    assert p.check == false
    assert p.present
    @test = "hello"
    assert p.check
    assert p.present == false
  end

  def test_artifact_check_page_custom_present_last
    p = Parfait::Page.new(:name => "p")
    p.add_check {
      @test == "hello"
    }
    p.add_present {
      @test == "goodbye"
    }
    @test = nil
    assert p.check == false
    assert p.present == false
    @test = "goodbye"
    assert p.check == false
    assert p.present
    @test = "hello"
    assert p.check
    assert p.present == false
  end

  def test_artifact_page_present_defined
    p = Parfait::Page.new(:name => "p")
    assert p.is_present_defined? == false
    p.add_check {
      @test == "hello"
    }
    assert p.is_present_defined?
  end

  def test_artifact_page_presence_check_calling_region
    p = Parfait::Page.new(:name => "p")
    p.add_check {
      @test == "hello"
    }
    r = Parfait::Region.new(:name => "r")
    r.add_filter { |a,b| b }
    p.add_region(r)

    @test = "hello"
    p.region("r" => "data")
    @test = "goodbye"
    assert_raises(RuntimeError) { 
      p.region("r" => "data")
    }
  end

  def test_artifact_page_presence_check_calling_control
    p = Parfait::Page.new(:name => "p")
    p.add_check {
      @test == "hello"
    }
    c = Parfait::Control.new(:name => "c",:logtext => "l")
    p.add_control(c)

    @test = "hello"
    p.control("c")
    @test = "goodbye"
    assert_raises(RuntimeError) { 
      p.control("c")
    }
  end


  ##################################################
  #
  # Region
  #
  ##################################################
  def test_artifact_check_region_generic_present
    r = Parfait::Region.new(:name => "r")
    r.add_check {
      @test == "hello"
    }
    @test = nil
    assert r.check == false
    assert r.present == false
    @test = "goodbye"
    assert r.check == false
    assert r.present == false
    @test = "hello"
    assert r.check
    assert r.present
  end

  def test_artifact_check_region_custom_present_first
    r = Parfait::Region.new(:name => "r")
    r.add_present {
      @test == "goodbye"
    }
    r.add_check {
      @test == "hello"
    }
    @test = nil
    assert r.check == false
    assert r.present == false
    @test = "goodbye"
    assert r.check == false
    assert r.present
    @test = "hello"
    assert r.check
    assert r.present == false
  end

  def test_artifact_check_region_custom_present_last
    r = Parfait::Region.new(:name => "r")
    r.add_check {
      @test == "hello"
    }
    r.add_present {
      @test == "goodbye"
    }
    @test = nil
    assert r.check == false
    assert r.present == false
    @test = "goodbye"
    assert r.check == false
    assert r.present
    @test = "hello"
    assert r.check
    assert r.present == false
  end

  def test_artifact_region_present_defined
    r = Parfait::Region.new(:name => "r")
    assert r.is_present_defined? == false
    r.add_check {
      @test == "hello"
    }
    assert r.is_present_defined?
  end

  def test_artifact_region_presence_check_calling_region
    r = Parfait::Region.new(:name => "r")
    r.add_filter { |a,b| b }
    r.add_check {
      @test == "hello"
    }
    s = Parfait::Region.new(:name => "s")
    s.add_filter { |a,b| b }
    r.add_region(s)

    @test = "hello"
    r.region("s" => "data")
    @test = "goodbye"
    assert_raises(RuntimeError) { 
      r.region("s" => "data")
    }
  end

  def test_artifact_region_presence_check_calling_control
    r = Parfait::Region.new(:name => "r")
    r.add_filter { |a,b| b }
    r.add_check {
      @test == "hello"
    }
    c = Parfait::Control.new(:name => "c",:logtext => "l")
    r.add_control(c)

    @test = "hello"
    r.control("c")
    @test = "goodbye"
    assert_raises(RuntimeError) { 
      r.control("c")
    }
  end


  ##################################################
  #
  # Region
  #
  ##################################################
  def test_artifact_check_control_generic_present
    c = Parfait::Control.new(:name => "c",:logtext => "l")
    c.add_check {
      @test == "hello"
    }
    @test = nil
    assert c.check == false
    assert c.present == false
    @test = "goodbye"
    assert c.check == false
    assert c.present == false
    @test = "hello"
    assert c.check
    assert c.present
  end

  def test_artifact_check_control_custom_present_first
    c = Parfait::Control.new(:name => "c",:logtext => "l")
    c.add_present {
      @test == "goodbye"
    }
    c.add_check {
      @test == "hello"
    }
    @test = nil
    assert c.check == false
    assert c.present == false
    @test = "goodbye"
    assert c.check == false
    assert c.present
    @test = "hello"
    assert c.check
    assert c.present == false
  end

  def test_artifact_check_control_custom_present_last
    c = Parfait::Control.new(:name => "c",:logtext => "l")
    c.add_check {
      @test == "hello"
    }
    c.add_present {
      @test == "goodbye"
    }
    @test = nil
    assert c.check == false
    assert c.present == false
    @test = "goodbye"
    assert c.check == false
    assert c.present
    @test = "hello"
    assert c.check
    assert c.present == false
  end

  def test_artifact_control_present_defined
    c = Parfait::Control.new(:name => "c",:logtext => "l")
    assert c.is_present_defined? == false
    c.add_check {
      @test == "hello"
    }
    assert c.is_present_defined?
  end

  def test_artifact_control_presence_check_calling_directives
    c = Parfait::Control.new(:name => "c",:logtext => "l")
    c.add_check {
      @test == "hello"
    }
    @val = nil
    c.add_set { |value| @val = value }
    c.add_get { @val }
    c.add_goto { @val = "goto" }

    @test = "hello"
    c.goto
    c.get
    c.set "x"
    c.navigate
    c.retrieve
    c.update "x"
    c.confirm "x"
    c.verify "x"
    @test = "goodbye"
    assert_raises(RuntimeError) { c.goto }
    assert_raises(RuntimeError) { c.get }
    assert_raises(RuntimeError) { c.set "x" }
    assert_raises(RuntimeError) { c.navigate }
    assert_raises(RuntimeError) { c.retrieve }
    assert_raises(RuntimeError) { c.update "x" }
    assert_raises(RuntimeError) { c.confirm "x" }
    assert_raises(RuntimeError) { c.verify "x" }
  end

end

