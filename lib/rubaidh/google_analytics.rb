require 'active_support'
require 'action_pack'
require 'action_view'

module Rubaidh # :nodoc:
  # This module gets mixed in to ActionController::Base
  module GoogleAnalyticsMixin
    # The javascript code to enable Google Analytics on the current page.
    # Normally you won't need to call this directly; the +add_google_analytics_code+
    # after filter will insert it for you.
    def google_analytics_code(opt = {})
      options = {:ssl => request.ssl?}.merge(opt)
      GoogleAnalytics.google_analytics_code(options) if GoogleAnalytics.enabled?(request.format)
    end

    # An after_filter to automatically add the analytics code.
    # If you intend to use the link_to_tracked view helpers, you need to set Rubaidh::GoogleAnalytics.defer_load = false
    # to load the code at the top of the page
    # (see http://www.google.com/support/googleanalytics/bin/answer.py?answer=55527&topic=11006)
    def add_google_analytics_code(options = {})
      if GoogleAnalytics.defer_load
        append_to_body(/<\/body>/i, "#{google_analytics_code(options)}</body>")
      else
        append_to_body(/(<body[^>]*>)/i, "\\1#{google_analytics_code(options)}")
      end
    end
  end

  class GoogleAnalyticsConfigurationError < StandardError; end

  # The core functionality to connect a Rails application
  # to a Google Analytics installation.
  class GoogleAnalytics

    @@tracker_id = nil
    ##
    # :singleton-method:
    # Specify the Google Analytics ID for this web site. This can be found
    # as the value of +_getTracker+ if you are using the new (ga.js) tracking
    # code, or the value of +_uacct+ if you are using the old (urchin.js)
    # tracking code.
    cattr_accessor :tracker_id

    @@domain_name = nil
    ##
    # :singleton-method:
    # Specify a different domain name from the default. You'll want to use
    # this if you have several subdomains that you want to combine into
    # one report. See the Google Analytics documentation for more
    # information.
    cattr_accessor :domain_name

    @@legacy_mode = false
    ##
    # :singleton-method:
    # Specify whether the legacy Google Analytics code should be used. By
    # default, the new Google Analytics code is used.
    cattr_accessor :legacy_mode

    @@analytics_url = 'http://www.google-analytics.com/urchin.js'
    ##
    # :singleton-method:
    # The URL that analytics information is sent to. This defaults to the
    # standard Google Analytics URL, and you're unlikely to need to change it.
    # This has no effect unless you're in legacy mode.
    cattr_accessor :analytics_url

    @@analytics_ssl_url = 'https://ssl.google-analytics.com/urchin.js'
    ##
    # :singleton-method:
    # The URL that analytics information is sent to when using SSL. This defaults to the
    # standard Google Analytics URL, and you're unlikely to need to change it.
    # This has no effect unless you're in legacy mode.
    cattr_accessor :analytics_ssl_url

    @@environments = ['production']
    ##
    # :singleton-method:
    # The environments in which to enable the Google Analytics code. Defaults
    # to 'production' only. Supply an array of environment names to change this.
    cattr_accessor :environments

    @@formats = [:html, :all]
    ##
    # :singleton-method:
    # The request formats where tracking code should be added. Defaults to +[:html, :all]+. The entry for
    # +:all+ is necessary to make Google recognize that tracking is installed on a
    # site; it is not the same as responding to all requests. Supply an array
    # of formats to change this.
    cattr_accessor :formats

    @@defer_load = false
    ##
    # :singleton-method:
    # Set this to true (the default) if you want to load the Analytics javascript at
    # the bottom of page. Set this to false if you want to load the Analytics
    # javascript at the top of the page. The page will render faster if you set this to
    # true, but that will break the linking functions in Rubaidh::GoogleAnalyticsViewHelper.
    cattr_accessor :defer_load

    @@local_javascript = false
    ##
    # :singleton-method:
    # Set this to true to use a local copy of the ga.js (or urchin.js) file.
    # This gives you the added benefit of serving the JS directly from your
    # server, which in case of a big geographical difference between your server
    # and Google's can speed things up for your visitors. Use the
    # 'google_analytics:update' rake task to update the local JS copies.
    cattr_accessor :local_javascript

    ##
    # :singleton-method:
    # Set this to override the initialized domain name for a single render. Useful
    # when you're serving to multiple hosts from a single codebase. Typically you'd
    # set up a before filter in the appropriate controller:
    #    before_filter :override_domain_name
    #    def override_domain_name
    #      Rubaidh::GoogleAnalytics.override_domain_name  = 'foo.com'
    #   end
    cattr_accessor :override_domain_name

    ##
    # :singleton-method:
    # Set this to override the initialized tracker ID for a single render. Useful
    # when you're serving to multiple hosts from a single codebase. Typically you'd
    # set up a before filter in the appropriate controller:
    #    before_filter :override_tracker_id
    #    def override_tracker_id
    #      Rubaidh::GoogleAnalytics.override_tracker_id  = 'UA-123456-7'
    #   end
    cattr_accessor :override_tracker_id

    ##
    # :singleton-method:
    # Set this to override the automatically generated path to the page in the
    # Google Analytics reports for a single render. Typically you'd set this up on an
    # action-by-action basis:
    #    def show
    #      Rubaidh::GoogleAnalytics.override_trackpageview = "path_to_report"
    #      ...
    cattr_accessor :override_trackpageview

    @@search_engines = []
    ##
    # :singleton-method:
    # Add search engines that should be used by GA for search traffic statistics.
    cattr_accessor :search_engines

    # Return true if the Google Analytics system is enabled and configured
    # correctly for the specified format
    def self.enabled?(format)
      raise Rubaidh::GoogleAnalyticsConfigurationError if tracker_id.blank? || analytics_url.blank?
      environments.include?(Rails.env) && formats.include?(format && format.to_sym)
    end

    # Construct the javascript code to be inserted on the calling page
    def self.google_analytics_code(options = {})
      if local_javascript
	  return "<script src=\"#{LocalAssetTagHelper.new.javascript_path( 'ga.js' )}\" type=\"text/javascript\"></script>"
      end
      if options[:universal]
        options[:enhanced_ecommerce] ? universal_enhanced_code(options) : google_universal_code(options)
      else
        google_analytics_legacy_code(options)
      end
    end

    def self.google_analytics_legacy_code(options = {})

      extra_code = domain_name.blank? ? nil : "_gaq.push(['_setDomainName', #{domain_name.to_json}]);"
      unless override_domain_name.blank?
        extra_code = "_gaq.push(['_setDomainName',#{override_domain_name.to_json}]);"
        self.override_domain_name = nil
      end

      ecommerce_code = nil
      if options[:transaction]
        ecommerce_code = "\n_gaq.push(['_addTrans', #{options[:transaction].map {|i| i.to_json}.join(',')}]);\n"
        options[:items].each do |item|
          ecommerce_code << "_gaq.push(['_addItem', #{item.map {|i| i.to_json}.join(',')}]);\n"
        end
        ecommerce_code << "_gaq.push(['_trackTrans']);\n"
      end

      code = <<-HTML
	<script type="text/javascript">

	  var _gaq = _gaq || [];
	  _gaq.push(['_setAccount', '#{request_tracker_id}']);
	  #{extra_code}
	  #{ecommerce_code}
      HTML

      search_engines.each do |search_engine, query_name|
        code << "_gaq.push(['_addOrganic','#{search_engine}','#{query_name}']);"
      end

      code << <<-HTML
	  _gaq.push(['_trackPageview']);
	  (function() {
	    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
	    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
	    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
	  })();

	</script>
      HTML

      return code
    end

    def self.universal_enhanced_code(options = {})
      # https://developers.google.com/analytics/devguides/collection/analyticsjs/enhanced-ecommerce
      ecommerce_code = nil

      if options[:transaction]
        ecommerce_code = "\nga('require', 'ec');\n"
        # https://developers.google.com/analytics/devguides/collection/analyticsjs/enhanced-ecommerce#product-data
        # ga('ec:addProduct', {
        #       'id': 'P12345',
        #       'name': 'Android Warhol T-Shirt',
        #       'category': 'Apparel',
        #       'price': '29.20',
        #       'quantity': 1,
        #       'variant': 'Black'
        #     });
        options[:products_in_order].each do |product_hash|
          ecommerce_code << "ga('ec:addProduct', #{product_hash.to_json});\n"
        end
        # https://developers.google.com/analytics/devguides/collection/analyticsjs/enhanced-ecommerce#action-data
        # ga('ec:setAction', 'purchase', {          // Transaction details are provided in an actionFieldObject.
        #   'id': 'T12345',                         // (Required) Transaction id (string).
        #   'affiliation': 'Google Store - Online', // Affiliation (string).
        #   'revenue': '37.39',                     // Revenue (currency).
        #   'tax': '2.85',                          // Tax (currency).
        #   'shipping': '5.34',                     // Shipping (currency).
        # });
        ecommerce_code << "ga('ec:setAction', 'purchase', #{options[:transaction].to_json});\n"
      elsif options[:product_detail_options]
        ecommerce_code = "\nga('require', 'ec');\n"
        # https://developers.google.com/analytics/devguides/collection/analyticsjs/enhanced-ecommerce#product-data
        # ga('ec:addProduct', {
        #       'id': 'P12345',
        #       'name': 'Android Warhol T-Shirt',
        #       'category': 'Apparel',
        #       'price': '29.20',
        #     });
        ecommerce_code << "ga('ec:addProduct', #{options[:product_detail_options].to_json});\n"
        ecommerce_code << "ga('ec:setAction', 'detail');\n"
      end

      code = <<-HTML
        <script type="text/javascript">
          (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
          (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
          m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
          })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

          ga('create', '#{request_tracker_id}');
          #{ecommerce_code}
          ga('send', 'pageview');

        </script>
      HTML

      code
    end

    def self.google_universal_code(options = {})

      # В Universal некоторые опции еперь указываются не отдельно, а параметрами ga('create')
      create_options = {}
      create_options['legacyCookieDomain'] = domain_name unless domain_name.blank?
      unless override_domain_name.blank?
        create_options['legacyCookieDomain'] = override_domain_name
        self.override_domain_name = nil
      end

      ecommerce_code     = nil
      # Список параметров нужен для получения JSON-хеша из массива со значениями в определенном порядке
      # но без ключей
      transaction_params = ['id', 'affiliation', 'revenue', 'tax', 'shipping']
      item_params	 = ['id', 'sku', 'name', 'category', 'price', 'quantity']
      if options[:transaction]
	ecommerce_code = "\nga('require', 'ecommerce');\n"
	# Объяснение метода zip на примере
	# arr1 = ['a', 'b']
	# arr2 = [1, 2]
	# arr1.zip arr2 # => [['a', 1], ['b', 2]]
	# Hash[ [['a', 1], ['b', 2]] ] # => {'a' => 1, 'b' => 2}
        ecommerce_code << "ga('ecommerce:addTransaction', #{Hash[ transaction_params.zip (options[:transaction].map {|i| i.to_s}) ].to_json});\n"
        options[:items].each do |item|
          ecommerce_code << "ga('ecommerce:addItem', #{Hash[ item_params.zip (item.map {|i| i.to_s}) ].to_json});\n"
        end
        ecommerce_code << "ga('ecommerce:send');\n"
      end

      code= <<-HTML
	<script type="text/javascript">
	  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

	  ga('create', '#{request_tracker_id}', 'auto'#{create_options.empty? ? '' : ", #{create_options.to_json}" });
	  #{ecommerce_code}
	  ga('send', 'pageview');

        </script>
      HTML

      return code
    end

    # Determine the tracker ID for this request
    def self.request_tracker_id
      use_tracker_id = override_tracker_id.blank? ? tracker_id : override_tracker_id
      self.override_tracker_id = nil
      use_tracker_id
    end

    # Determine the path to report for this request
    def self.request_tracked_path
      use_tracked_path = override_trackpageview.blank? ? '' : "'#{override_trackpageview}'"
      self.override_trackpageview = nil
      use_tracked_path
    end

  end

  class LocalAssetTagHelper # :nodoc:
    # For helping with local javascripts
    include ActionView::Helpers::AssetTagHelper
  end
end
