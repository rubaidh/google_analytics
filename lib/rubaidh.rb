require 'rubaidh/google_analytics'
require 'rubaidh/view_helpers'
require 'rubaidh/railtie' if defined?(Rails)

module Rubaidh #:nodoc:
end

ActionController::Base.send :include, Rubaidh::GoogleAnalyticsMixin
