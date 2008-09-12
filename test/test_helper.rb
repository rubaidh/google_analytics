ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'test/unit'
require 'action_controller'
require 'active_record'

require File.expand_path(File.dirname(__FILE__) + '/../lib/rubaidh/google_analytics.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/rubaidh/view_helpers.rb')

