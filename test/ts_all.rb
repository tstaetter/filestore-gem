#!/usr/bin/env ruby
#
# ts_all.rb
#
# @author Thomas Stätter
# @date 2014-01-05
#
require 'test/unit'

Dir['./tc_*.rb'].each do |tc|
  require tc
end
