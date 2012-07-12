#!/usr/bin/env jruby

$: << File.join(File.dirname(__FILE__), "..", "lib")

require "mquby"

include MQuby::DSL

broker "broker", :port => 61613 do
  topic "test.topic", "test", "test", "test"
  user  "test", "secret", ["test", "everyone", "admins"]
end