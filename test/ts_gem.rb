#!/usr/bin/env ruby
#
# ts_gem.rb
# @author Thomas Stätter
# @date 10.07.2012
# @description Test suite for the complete gem
#

# execute test using: ruby -I../lib/ -I. ts_gem.rb
$:.unshift('.')
$:.unshift('../lib')

require "test/unit"
require 'tc_action.rb'
require 'tc_meta.rb'
require 'tc_log.rb'
require 'tc_filestore.rb'