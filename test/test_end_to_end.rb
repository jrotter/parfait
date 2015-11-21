require 'minitest/autorun'
require 'test_helper'

class EndToEndTest < Minitest::Test

  def setup
    Parfait::set_logroutine { |string| } # no need to log anything
  end

  def test_parfait_end_to_end_1
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
