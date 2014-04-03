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

      desc "add a new pull source of specified type (stash, github)"
      long_desc <<-DESC
      Add a new pull request source. Source type can be 'stash' or 'github'.
      If source type is not provided as an argument you will be prompted to
      select one.
      DESC
      arg_name '[source type]'
      command :'add-source' do |add|
        add.action do |global_options, options, args|
          Pra::Cli::Source.new.add(args.first)
        end
      end

      desc "add a new repository to one of your pull sources"
      long_desc "Add a new repository to a pull source. This command takes no arguments and will launch an interactive menu to select a source and define the repo."
      command :'add-repo' do |add|
        add.action do |global_options, options, args|
          Pra::Cli::Repo.new.add
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