#!/usr/bin/env jruby

$: << File.join(File.dirname(__FILE__), "..", "lib")

require "mquby"

include MQuby::DSL

broker "broker", :port => 61613 do
  topic "test.topic", "test", "test", "test"
  user  "test", "secret", ["test", "everyone", "admins"]
  transport "stomp2", "stomp://localhost:61614"

  system_usage :store, "50MB"
  system_usage :memory, "512kB"
  system_usage :temp, "10MB"
end


