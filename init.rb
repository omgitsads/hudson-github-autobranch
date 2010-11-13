require 'rubygems'

require 'bundler'
Bundler.require

CONFIG_FILE = 'config.yml' unless defined?(CONFIG_FILE)

require File.join(File.dirname(__FILE__), 'lib/hudhub.rb')

