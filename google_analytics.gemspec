spec = Gem::Specification.new do |s|
  s.name              = 'google_analytics'
  s.version           = '1.1.4'
  s.date              = "2009-04-28"
  s.author            = 'Graeme Mathieson'
  s.email             = 'mathie@rubaidh.com'
  s.has_rdoc          = true
  s.rubyforge_project = "rubaidh"
  s.homepage          = 'http://rubaidh.com/portfolio/open-source/google-analytics/'
  s.summary           = "[Rails] Easily enable Google Analytics support in your Rails application."

  s.description = 'By default this gem will output google analytics code for' +
                  "every page automatically, if it's configured correctly." +
                  "This is done by adding:\n" +
                  "Rubaidh::GoogleAnalytics.tracker_id = 'UA-12345-67'\n"
                  'to your `config/environment.rb`, inserting your own tracker id.'
                  'This can be discovered by looking at the value assigned to +_uacct+' +
                  'in the Javascript code.'
  
  s.files = %w( CREDITS MIT-LICENSE README.rdoc Rakefile rails/init.rb
                test/google_analytics_test.rb
                test/test_helper.rb
                test/view_helpers_test.rb
                lib/rubaidh.rb
                lib/rubaidh/google_analytics.rb
                lib/rubaidh/view_helpers.rb
                tasks/google_analytics.rake)

  s.add_dependency 'actionpack'
  s.add_dependency 'activesupport'
end
