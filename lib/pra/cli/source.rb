# require 'thor'
require 'highline/import'
require 'pra/config'

module Pra
  module Cli
    class Source
      def add(source_type = nil)
        source = build_pull_source(source_type)
        pra_config = Pra::Config.load_config_or_default
        pra_config.add_pull_source(source)
        pra_config.write_config
      end

      private
      def build_pull_source(source_type)
        config = {}
        source = {}
        source[:type] = collect_source_type(source_type)
        config[:host] = collect_host(source[:type])
        config[:protocol] = collect_protocol
        config[:username] = collect_username
        config[:password] = collect_password
        config[:repositories] = []
        source[:config] = config
        source
      end

      def collect_source_type(source_type)
        HighLine.choose do |menu|
          menu.prompt = "Source type: "
          menu.first_answer = source_type
          menu.choices('github', 'stash') do |choice|
            HighLine.say "Adding a #{choice} pull source"
            choice
          end
        end
      end

      def collect_host(source_type = nil)
        HighLine.ask("Host:") do |q|
          q.default = 'api.github.com' if source_type.eql?('github')
          q.whitespace = :strip
          q.validate = -> (host) { host.length > 0 }
          q.responses[:not_valid] = 'Host is required'
        end
      end

      def collect_protocol
        https = HighLine.agree("https? [Y/n]") do |q|
          q.default = 'y'
        end
        https ? 'https' : 'http'
      end

      def collect_username
        HighLine.ask("Username:") do |q|
          q.whitespace = :strip
          q.validate = -> (answer) { answer.length > 0 }
          q.responses[:not_valid] = 'Username is required'
        end
      end

      def collect_password
        HighLine.ask("Password:") do |q|
          q.echo = false
          q.validate = -> (answer) { answer.length > 0 }
          q.responses[:not_valid] = 'Password is required'
        end
      end
    end
  end
end