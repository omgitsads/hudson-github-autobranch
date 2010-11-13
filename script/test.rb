require 'pp'
require 'rubygems'

require 'bundler'
Bundler.require

CONFIG_FILE = 'config.yml'
require File.join(File.dirname(__FILE__), '..', 'lib', 'hudhub')

pp j = Hudhub::Hudson::Job.find('EFT3-Test')

p j.update_branch('sweet-branch')

pp Hudhub::Hudson::Job.create!('EFT3-Test (sweet-branch)', j.data)

pp Hudhub::Hudson::Job.run!('EFT3-Test (sweet-branch)')

