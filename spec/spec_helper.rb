$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'safe_eval'
require 'spec'
require 'spec/autorun'
require 'mharris_ext'

Spec::Runner.configure do |config|
  
end

def debug_log(*args)
end
