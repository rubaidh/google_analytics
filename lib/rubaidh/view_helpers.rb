module Rubaidh
  module GoogleAnalyticsViewHelper #:nodoc:
      def link_to_tracked(name, track_path = "/", options = {}, html_options = {})
        html_options.merge!({:onclick => "pageTracker._trackPageview('#{track_path}');"})
        link_to(name, options, html_options)
    end
  end
end

