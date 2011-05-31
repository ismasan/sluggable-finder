#!/usr/bin/env ruby -w
# encoding: UTF-8
$KCODE = "UTF-8"

require 'rubygems'
require 'bundler'
Bundler.setup

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'rspec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'sluggable_finder'