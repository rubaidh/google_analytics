module Rubaidh # :nodoc:
  module GoogleAnalyticsMixin
    def add_google_analytics_code
      GoogleAnalytics.new.add_google_analytics_code
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

    def add_google_analytics_code
      # Insert the Google analytics code into the end of the outgoing
      # page, just before the </body> tag.
      code = <<-HTML
      <script src="#{analytics_url}" type="text/javascript">
      </script>
      <script type="text/javascript">
      _uacct = "#{tracker_id}";
      urchinTracker();
      </script>
      HTML
      code if environments.include?(RAILS_ENV) and tracker_id and analytics_url
    end
  end
end