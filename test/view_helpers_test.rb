require File.dirname(__FILE__) + '/test_helper.rb'
include Rubaidh::GoogleAnalyticsViewHelper
include ActionView::Helpers::UrlHelper
include ActionView::Helpers::TagHelper

class ViewHelpersTest < Test::Unit::TestCase
  def test_link_to_tracked_should_return_a_tracked_link
    assert_equal "<a href=\"http://www.example.com\" onclick=\"pageTracker._trackPageview('/sites/linked');\">Link</a>", link_to_tracked('Link', '/sites/linked', "http://www.example.com" )
  end
end
