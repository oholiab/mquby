require 'yaml'
require 'singleton'

module MQuby
  class Config
    include Singleton

    def self.loadconfig(file)
      @@config = parse file
    end

    def self.parse(file)
      YAML.load_file(file)
    rescue Errno::ENOENT
      raise ConfigParseError "Config file #{file} does not exist"
    end

    def self.config
      raise ConfigParseError "No config file loaded (use loadconfig)" unless @@config
      @@config
    end
  end

  class ConfigParseError < RuntimeError; end

end
