module MQuby
  module DSL

    include_class "org.apache.activemq.broker.BrokerService"
    include_class "org.apache.activemq.broker.BrokerPlugin"
    include_class "org.apache.activemq.broker.TransportConnector"
    include_class "org.apache.activemq.usage.SystemUsage"
    include_class "org.apache.activemq.security.SimpleAuthenticationPlugin"
    include_class "org.apache.activemq.security.AuthorizationPlugin"
    include_class "org.apache.activemq.security.AuthorizationEntry"
    include_class "org.apache.activemq.security.DefaultAuthorizationMap"
    include_class "org.apache.activemq.security.AuthorizationMap"
    include_class "org.apache.activemq.security.AuthenticationUser"
    include_class "java.net.URI"

    @@acls = []
    @@users = []
    @@transports = []

    def user(name, password, groups)
      user = AuthenticationUser.new(name, password, groups.join(","))
      @@users << user
    end

    def topic(name, read, write, admin)
      @@acls << {:topic => name, :read => read, :write => write, :admin => "admin"}
    end

    def transport(name, uri)
      transport = TransportConnector.new
      transport.name = name
      transport.uri = URI.new(uri)
      @@transports << transport
    end

    def broker(name, options)
      yield
      authentication = SimpleAuthenticationPlugin.new
      authentication.users = @@users
      auth_map = DefaultAuthorizationMap.new
      @@acls.each do |acl|
        auth_entry = AuthorizationEntry.new
        auth_entry.topic = acl[:topic] if acl[:topic]
        auth_entry.queue = acl[:queue] if acl[:queue]
        auth_entry.read = acl[:read]
        auth_entry.write = acl[:write]
        auth_entry.admin = acl[:admin]
      
        auth_map.put auth_entry.destination, auth_entry
      end

      authorization = AuthorizationPlugin.new(auth_map)

      broker = BrokerService.new

      broker.broker_name = name

      broker.plugins = [authorization, authentication]

      port = options.fetch(:port) {61613}

      broker.add_connector("stomp://localhost:#{port}")
      @@transports.each {|t| broker.add_connector(t)}
      broker.start
      broker
    end
  end
end
