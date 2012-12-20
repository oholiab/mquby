require 'mquby/helpers'

module MQuby
  module DSL

    include_class "org.apache.activemq.broker.BrokerService"
    include_class "org.apache.activemq.broker.BrokerPlugin"
    include_class "org.apache.activemq.broker.TransportConnector"
    include_class "org.apache.activemq.usage.SystemUsage"
    include_class "org.apache.activemq.usage.MemoryUsage"
    include_class "org.apache.activemq.usage.StoreUsage"
    include_class "org.apache.activemq.usage.TempUsage"
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
    @@systemusage = SystemUsage.new

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

    def system_usage(resource, resourcelimit)

      limit = resourcelimit.to_sizeinbytes

      case resource
      when :memory
        memory = MemoryUsage.new
        memory.limit = limit
        memory.percent_usage_min_delta = 20
        @@systemusage.memory_usage = memory
        return
      when :store
        store = StoreUsage.new
        store.limit = limit
        @@systemusage.store_usage = store
        return
      when :temp
        temp = TempUsage.new
        temp.limit = limit
        @@systemusage.temp_usage = temp
        return
      end

      raise DSLError "Resource type #{resource.to_s} not recognised"

    rescue TypeError => e
      raise DSLError "#{e.class}: #{e}"
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

      broker.system_usage = @@systemusage if @@systemusage

      broker.broker_name = name

      broker.plugins = [authorization, authentication]

      port = options.fetch(:port) {61613}

      broker.add_connector("stomp://localhost:#{port}")
      @@transports.each {|t| broker.add_connector(t)}
      broker.start
      broker
    end


    def method_missing(method, *args, &block)
      raise DSLError "Method #{method} not known"
    end


    class DSLError < RuntimeError; end
  end
end
