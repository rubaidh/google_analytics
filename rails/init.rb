require 'rubaidh/google_analytics'
require 'rubaidh/view_helpers'
ActionController::Base.send :include, Rubaidh::GoogleAnalyticsMixin
