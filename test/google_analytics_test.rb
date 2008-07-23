require File.dirname(__FILE__) + '/test_helper.rb'
require 'test/unit'

class GoogleAnalyticsTest < Test::Unit::TestCase
  def setup
    @ga = Rubaidh::GoogleAnalytics.new
    @ga.send('class_reset')
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
    @ga.tracker_id = nil
    assert_raise(Rubaidh::GoogleAnalyticsConfigurationError) { Rubaidh::GoogleAnalytics.enabled?(:html) }
  end
  
  def test_enabled_requires_analytics_url
    @ga.analytics_url = nil
    assert_raise(Rubaidh::GoogleAnalyticsConfigurationError) { Rubaidh::GoogleAnalytics.enabled?(:html) }
  end
  
  def test_enabled_returns_false_if_current_environment_not_enabled
    assert_equal(false, Rubaidh::GoogleAnalytics.enabled?(:html))
  end
  
  def test_enabled_with_default_format
    @ga.environments << 'test'
    assert_equal(true, Rubaidh::GoogleAnalytics.enabled?(:html))
  end
  
  def test_enabled_with_not_included_format
    @ga.environments << 'test'
    assert_equal(false, Rubaidh::GoogleAnalytics.enabled?(:xml))
  end
  
  def test_enabled_with_added_format
    @ga.environments << 'test'
    @ga.formats << :xml
    assert_equal(true, Rubaidh::GoogleAnalytics.enabled?(:xml))
  end
  
end
