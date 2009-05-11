ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'test/unit'

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'google_analytics'
