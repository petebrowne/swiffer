require 'rubygems'
require 'spec'
require 'rr'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'swiffer'

Spec::Runner.configure do |config|
  config.mock_with :rr
end
