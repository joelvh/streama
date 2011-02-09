$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'streama'
require 'mongoid'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Mongoid.configure do |config|
  name = "streama-rspec-test"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
end

require 'mongoid-rspec'

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.include Mongoid::Matchers
  config.mock_with :rspec
  config.after :all do
    Mongoid.master.collections.each(&:drop)
  end
end
