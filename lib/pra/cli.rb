require 'pra/app'
require 'pra/cli/source'
require 'pra/cli/repo'
require 'thor'
require 'highline/import'

module Pra
  module Cli
    class Main < Thor
      register Pra::Cli::Repo, :repo, "repo SUBCOMMAND", "Manage repositories. See `pra repo help` for details."
      register Pra::Cli::Source, :source, "source SUBCOMMAND", "Manage pull sources. See `pra source help` for details."

      default_task :launch
      desc "launch", "Start pra"
      def launch
        Pra::App.new.run
      end

      subcommand "source", Pra::Cli::Source
      subcommand "repo", Pra::Cli::Repo
    end
  end
end