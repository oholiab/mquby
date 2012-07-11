#!/usr/bin/env ruby

require "java"
require "activemq-all-5.5.1.jar"
require "lib/optional/slf4j-log4j12-1.5.11.jar"
require "lib/optional/log4j-1.2.14.jar"
require "lib/optional/xstream-1.3.1.jar"

org.apache.log4j.BasicConfigurator.configure

include_class "org.apache.activemq.broker.BrokerService"
include_class "org.apache.activemq.broker.BrokerPlugin"
include_class "org.apache.activemq.security.SimpleAuthenticationPlugin"
include_class "org.apache.activemq.security.AuthorizationPlugin"
include_class "org.apache.activemq.security.AuthorizationEntry"
include_class "org.apache.activemq.security.DefaultAuthorizationMap"
include_class "org.apache.activemq.security.AuthorizationMap"
include_class "org.apache.activemq.security.AuthenticationUser"


# create a list of user and make my user
users = []
users << AuthenticationUser.new("rip", "secret", "rip,admins,everyone")
users << AuthenticationUser.new("admin", "secret", "admin,admins,everyone")

# add the users to the authentication plugin
authentication = SimpleAuthenticationPlugin.new
authentication.users = users

# now create a map full of ACLs
auth_map = DefaultAuthorizationMap.new

acls = []

acls << {:topic => "rip.test", :read => "rip", :write => "rip", :admin => "rip"}
acls << {:topic => "ActiveMQ.Advisory.>", :read => "everyone", :write => "everyone", :admin => "everyone"}

acls.each do |acl|
  auth_entry = AuthorizationEntry.new
  auth_entry.topic = acl[:topic] if acl[:topic]
  auth_entry.queue = acl[:queue] if acl[:queue]
  auth_entry.read = acl[:read]
  auth_entry.write = acl[:write]
  auth_entry.admin = acl[:admin]

  auth_map.put auth_entry.destination, auth_entry
end

# create the authorization plugin and add the map
authorization = AuthorizationPlugin.new(auth_map)

# create the broker and install plugins
broker = BrokerService.new

broker.broker_name = "jruby"

broker.plugins = [authorization, authentication]

broker.add_connector("stomp://localhost:61613")
broker.start
