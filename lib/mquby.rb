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

require "mquby/dsl"
