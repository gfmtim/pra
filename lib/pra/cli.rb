require 'pra/app'
require 'pra/cli/source'
require 'pra/cli/repo'
require 'thor'
require 'highline/import'

module Pra
  module Cli
    class Main < Thor
      default_task :launch
      desc "launch", "Start pra"
      def launch
        Pra::App.new.run
      end

      desc "source", "source SUBCOMMAND"
      subcommand "source", Pra::Cli::Source

      desc "repo", "repo SUBCOMMAND"
      subcommand "repo", Pra::Cli::Repo
    end
  end
end