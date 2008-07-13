module Rubaidh
  module GoogleAnalyticsViewHelper #:nodoc:
    def link_to_tracked(name, track_path = "/", options = {}, html_options = {})
      
      html_options.merge!({:onclick => tracking_call(track_path)})
      link_to name, options, html_options
    end
    
    def link_to_tracked_if(condition, name, track_path = "/", options = {}, html_options = {}, &block)
      html_options.merge!({:onclick => tracking_call(track_path)})
      link_to_unless !condition, name, options, html_options, &block
    end
    
    def link_to_tracked_unless(condition, name, track_path = "/", options = {}, html_options = {}, &block)
      html_options.merge!({:onclick => tracking_call(track_path)})
      link_to_unless condition, name, options, html_options, &block
    end
    
    def link_to_tracked_unless_current(name, track_path = "/", options = {}, html_options = {}, &block)
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
end

