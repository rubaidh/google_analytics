module Rubaidh # :nodoc:
  module GoogleAnalyticsMixin
    def google_analytics_code
      return unless GoogleAnalytics.enabled?
      GoogleAnalytics.new.google_analytics_code
    end
    
    # An after_filter to automatically add the analytics code.
    def add_google_analytics_code
      code = google_analytics_code
      return if code.blank?
      response.body.gsub! '</body>', code + '</body>'
    end
  end

  class GoogleAnalytics
    # Specify the Google Analytics ID for this web site.  This can be found
    # as the value of +_uacct+ in the Javascript excerpt
    @@tracker_id = nil
    cattr_accessor :tracker_id

    # I can't see why you'd want to do this, but you can always change the
    # analytics URL.
    @@analytics_url = 'http://www.google-analytics.com/urchin.js'
    cattr_accessor :analytics_url

    # The environments in which to enable the Google Analytics code.  Defaults
    # to 'production' only.
    @@environments = ['production']
    cattr_accessor :environments

    # Return true if the Google Analytics system is enabled and configured
    # correctly.
    def self.enabled?
      (environments.include?(RAILS_ENV) and
        not tracker_id.blank? and
        not analytics_url.blank?)
    end
    
    def google_analytics_code
      # OK, I'm not very bright -- I tried to turn this into a partial and
      # failed miserably!  So it'll have to live here for now.
      code = <<-HTML
      <script src="#{analytics_url}" type="text/javascript">
      </script>
      <script type="text/javascript">
      _uacct = "#{tracker_id}";
      urchinTracker();
      </script>
      HTML
      code
    end
  end
end