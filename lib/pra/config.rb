require 'json'

module Pra
  class Config
    def initialize(initial_config = {})
      @initial_config = initial_config
    end

    def self.load_config
      return self.new(self.parse_config_file)
    end

    def self.parse_config_file
      self.json_parse(self.read_config_file)
    end

    def self.read_config_file
      file = File.open(self.config_path, "r")
      contents = file.read
      file.close
      return contents
    end

    def self.load_config_or_default
      if config_exists?
        load_config
      else
        self.new({ 'pull_sources' => [] })
      end
    end

    def self.write_config_file(config)
      if config_exists?
        FileUtils.cp(config_path, config_path + '.bak')
      end

      File.open(config_path, 'w') do |file|
        file.write(JSON::pretty_generate(config))
      end
    end

    def self.config_exists?
      File.exists?(config_path)
    end

    def self.config_path
      return File.join(self.users_home_directory, '.pra.json')
    end

    def self.error_log_path
      return File.join(self.users_home_directory, '.pra.errors.log')
    end

    def self.users_home_directory
      return ENV['HOME']
    end

    def self.json_parse(content)
      return JSON.parse(content)
    end

    def pull_sources
      @initial_config["pull_sources"]
    end

    def assignee_blacklist
      @initial_config["assignee_blacklist"]
    end

    def write_config
      Pra::Config.write_config_file(@initial_config)
    end

    def add_pull_source(pull_source)
      pull_sources.push(pull_source)
    end
  end
end
