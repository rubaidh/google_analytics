module Rubaidh # :nodoc:
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/google_analytics.rake"
    end
  end
end
