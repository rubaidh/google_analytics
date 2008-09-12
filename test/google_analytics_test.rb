require File.dirname(__FILE__) + '/test_helper.rb'
require 'test/unit'
require 'rubygems'
require 'mocha'
RAILS_ENV = 'test'

class GoogleAnalyticsTest < Test::Unit::TestCase
  def setup
    @ga = Rubaidh::GoogleAnalytics.new
    @ga.tracker_id = "the tracker id"
  end
  
  def test_createable
    assert_not_nil(@ga)
  end
  
  def test_domain_name_defaults_to_nil
    assert_nil(@ga.domain_name)
  end
  
  def test_legacy_mode_defaults_to_false
    assert_equal(false, @ga.legacy_mode)
  end
  
  def test_default_analytics_url
    assert_equal("http://www.google-analytics.com/urchin.js", @ga.analytics_url)
  end
  
  def test_default_analytics_ssl_url
    assert_equal('https://ssl.google-analytics.com/urchin.js', @ga.analytics_ssl_url)
  end
  
  def test_default_environments
    assert_equal(false, @ga.environments.include?('test'))
    assert_equal(false, @ga.environments.include?('development'))
    assert_equal(true, @ga.environments.include?('production'))
  end
  
  def test_default_formats
    assert_equal(false, @ga.formats.include?(:xml))
    assert_equal(true, @ga.formats.include?(:html))
  end

  def test_defer_load_defaults_to_true
    assert_equal(true, @ga.defer_load)
  end
  
  def test_local_javascript_defaults_to_false
    assert_equal(false, @ga.local_javascript)
  end
  
  # test self.enabled
  def test_enabled_requires_tracker_id
    Rubaidh::GoogleAnalytics.stubs(:tracker_id).returns(nil)
    assert_raise(Rubaidh::GoogleAnalyticsConfigurationError) { Rubaidh::GoogleAnalytics.enabled?(:html) }
  end
  
  def test_enabled_requires_analytics_url
    Rubaidh::GoogleAnalytics.stubs(:analytics_url).returns(nil)
    assert_raise(Rubaidh::GoogleAnalyticsConfigurationError) { Rubaidh::GoogleAnalytics.enabled?(:html) }
  end
  
  def test_enabled_returns_false_if_current_environment_not_enabled
    Rubaidh::GoogleAnalytics.stubs(:environments).returns(['production'])
    assert_equal(false, Rubaidh::GoogleAnalytics.enabled?(:html))
  end
  
  def test_enabled_with_default_format
    Rubaidh::GoogleAnalytics.stubs(:environments).returns(['test'])
    assert_equal(true, Rubaidh::GoogleAnalytics.enabled?(:html))
  end
  
  def test_enabled_with_not_included_format
    Rubaidh::GoogleAnalytics.stubs(:environments).returns(['test'])
    assert_equal(false, Rubaidh::GoogleAnalytics.enabled?(:xml))
  end
  
  def test_enabled_with_added_format
    Rubaidh::GoogleAnalytics.stubs(:environments).returns(['test'])
    Rubaidh::GoogleAnalytics.stubs(:formats).returns([:xml])
    assert_equal(true, Rubaidh::GoogleAnalytics.enabled?(:xml))
  end

  # test request_tracker_id
  def test_request_tracker_id_without_override
    Rubaidh::GoogleAnalytics.stubs(:tracker_id).returns("1234")
    assert_equal("1234", Rubaidh::GoogleAnalytics.request_tracker_id)
  end
  
  def test_request_tracker_id_with_override
    Rubaidh::GoogleAnalytics.stubs(:tracker_id).returns("1234")
    Rubaidh::GoogleAnalytics.override_tracker_id = "4567"
    assert_equal("4567", Rubaidh::GoogleAnalytics.request_tracker_id)
  end
  
  def test_request_tracker_id_resets_override
    Rubaidh::GoogleAnalytics.override_tracker_id = "4567"
    Rubaidh::GoogleAnalytics.stubs(:tracker_id).returns("1234")
    foo = Rubaidh::GoogleAnalytics.request_tracker_id
    assert_nil(Rubaidh::GoogleAnalytics.override_tracker_id)
  end
  
  # test request_tracked_path
  def test_request_tracked_path_without_override
    assert_equal('', Rubaidh::GoogleAnalytics.request_tracked_path)
  end
  
  def test_request_tracked_path_with_override
    Rubaidh::GoogleAnalytics.override_trackpageview = "/my/path"
    assert_equal("'/my/path'", Rubaidh::GoogleAnalytics.request_tracked_path)
  end
  
  def test_request_tracked_path_resets_override
    Rubaidh::GoogleAnalytics.override_trackpageview = "/my/path"
    foo = Rubaidh::GoogleAnalytics.request_tracked_path
    assert_nil(Rubaidh::GoogleAnalytics.override_trackpageview)
  end
  
end
