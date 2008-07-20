module Rubaidh
  module GoogleAnalyticsViewHelper #:nodoc:
    def link_to_tracked(name, track_path = "/", options = {}, html_options = {})
      raise AnalyticsError.new("You must set Rubaidh::GoogleAnalytics.defer_load = false to use outbound link tracking") if GoogleAnalytics.defer_load == true
      html_options.merge!({:onclick => tracking_call(track_path)})
      link_to name, options, html_options
    end
    
    def link_to_tracked_if(condition, name, track_path = "/", options = {}, html_options = {}, &block)
      raise AnalyticsError.new("You must set Rubaidh::GoogleAnalytics.defer_load = false to use outbound link tracking") if GoogleAnalytics.defer_load == true
      html_options.merge!({:onclick => tracking_call(track_path)})
      link_to_unless !condition, name, options, html_options, &block
    end
    
    def link_to_tracked_unless(condition, name, track_path = "/", options = {}, html_options = {}, &block)
      raise AnalyticsError.new("You must set Rubaidh::GoogleAnalytics.defer_load = false to use outbound link tracking") if GoogleAnalytics.defer_load == true
      html_options.merge!({:onclick => tracking_call(track_path)})
      link_to_unless condition, name, options, html_options, &block
    end
    
    def link_to_tracked_unless_current(name, track_path = "/", options = {}, html_options = {}, &block)
      raise AnalyticsError.new("You must set Rubaidh::GoogleAnalytics.defer_load = false to use outbound link tracking") if GoogleAnalytics.defer_load == true
      html_options.merge!({:onclick =>tracking_call(track_path)})
      link_to_unless current_page?(options), name, options, html_options, &block
    end
    
private

    def tracking_call(track_path)
      if GoogleAnalytics.legacy_mode
        "javascript:urchinTracker('#{track_path}');"
      else
        "javascript:pageTracker._trackPageview('#{track_path}');"
      end
    end
    
  end
  
  class AnalyticsError < StandardError
    attr_reader :message
    
    def initialize(message)
      @message = message
    end
  end
end

