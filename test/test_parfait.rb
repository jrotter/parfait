require 'minitest/autorun'
require 'test_helper'

class ParfaitTest < Minitest::Test

  def test_parfait_set_and_use_logroutine_nohash
    @tempval = "cat"
    myroutine = lambda { |instring,opts|
      @tempval += " #{instring}"
    }
    Parfait.set_logroutine &myroutine
    Parfait.log "dog"
    assert @tempval == "cat dog"
  end

  def test_parfait_set_and_use_logroutine_hash
    @tempval = nil
    myroutine = lambda { |instring,opts|
      @tempval = "#{instring} #{opts[:data]}"
    }
    Parfait.set_logroutine &myroutine
    Parfait.log("cat",:stuff => "hello",:things => "goodbye",:data => "hat")
    assert @tempval == "cat hat"
  end

  def test_parfait_set_get_filter_browser
    a = "hello"
    b = "goodbye"
    Parfait::set_browser a
    assert Parfait::browser == a
    Parfait::filter_browser b
    assert Parfait::browser == b

    c = Watir::Browser.new
    Parfait::set_browser c
    assert Parfait::browser == c
    d = "umbrella"
    Parfait::filter_browser d
    assert Parfait::browser == d
  end

end
