#!/usr/bin/env jruby

require "java"
require "mquby/config"

include MQuby
Config.loadconfig ARGV[0]
jarfile = Config.config["activemqjar"]

require jarfile

mqloadpath = File.dirname jarfile
optionalsloadpath = [mqloadpath, "lib", "optional"].join("/")

#["slf4j-log4j12", "log4j", "xstream"].each do |jarfile|

["log4j", "xstream"].each do |jarfile|
  regex = Regexp.new(/^(#{jarfile}-.+)$/)
  jars = Dir.entries(optionalsloadpath).grep(regex)
  raise "Could not load #{jarfile} in #{optionalsloadpath}" unless jars.count > 0
  require [optionalsloadpath, jars[0]].join("/")
end

org.apache.log4j.BasicConfigurator.configure

include_class "org.apache.activemq.broker.BrokerService"
include_class "org.apache.activemq.broker.BrokerPlugin"
include_class "org.apache.activemq.security.SimpleAuthenticationPlugin"
include_class "org.apache.activemq.security.AuthorizationPlugin"
include_class "org.apache.activemq.security.AuthorizationEntry"
include_class "org.apache.activemq.security.DefaultAuthorizationMap"
include_class "org.apache.activemq.security.AuthorizationMap"
include_class "org.apache.activemq.security.AuthenticationUser"
