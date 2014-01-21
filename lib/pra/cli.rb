require 'pra/app'
require 'pra/cli/source'
require 'pra/cli/repo'
require 'pra/version'
require 'gli'
require 'highline/import'

module Pra
  module Cli
    class Main
      extend GLI::App
      version Pra::VERSION
      subcommand_option_handling :normal
      program_desc "CLI tool that shows open pull-requests across systems."

      desc "Manage pull sources"
      command :source do |c|
        c.desc "add a new pull source of specified type (stash, github)"
        c.long_desc <<-DESC
        Add a new pull request source. Source type can be 'stash' or 'github'.
        If source type is not provided as an argument you will be prompted to
        select one.
        DESC
        c.arg_name "[source type]"
        c.command :add do |add|
          add.action do |global_options, options, args|
            Pra::Cli::Source.new.add(args.first)
          end
        end
      end

      desc "Manage repositories"
      command :repo do |c|
        c.desc "add a new repository to one of your pull sources"
        c.command :add do |add|
          add.action do |global_options, options, args|
            Pra::Cli::Repo.new.add
          end
        end
      end

      desc "Start pra"
      command :start do |c|
        c.action do |global_options, options, args|
          Pra::App.new.run
        end
      end

      default_command :start
    end
  end
end