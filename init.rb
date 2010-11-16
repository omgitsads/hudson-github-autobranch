require 'rubygems'

require 'bundler'
Bundler.require

CONFIG_FILE = 'config.yml' unless defined?(CONFIG_FILE)

def log(msg)
  puts msg
end

require File.join(File.dirname(__FILE__), 'lib/hudhub.rb')

