require 'pra/config'
require 'thor'
require 'highline/import'

module Pra
  module Cli
    class Repo < Thor
      desc "add", "add a repo"
      def add
        pra_config = Pra::Config.load_config_or_default

        unless pra_config.pull_sources.any?
          HighLine.say("You'll need to add a pull source with `pra source add` first.")
          return
        end

        source = pick_source(pra_config.pull_sources)
        repo = collect_repo_info(source)
        add_repo_to_source(source, repo)
        pra_config.write_config
      end

      private
      def add_repo_to_source(source, repo)
        source['config']['repositories'] ||= []
        source['config']['repositories'].push(repo)
      end

      def pick_source(sources)
        index = HighLine.choose do |menu|
          sources.each_with_index do |source, index|
            menu.choice("(#{source['type']}) #{source['config']['host']}") { index }
          end
        end

        sources[index]
      end

      def collect_repo_info(source)
        case source['type']
        when 'stash'
          collect_stash_repo_info
        when 'github'
          collect_github_repo_info
        end
      end

      def collect_stash_repo_info
        project = collect_stash_project
        repo = collect_repo_name

        {
          project_slug: project,
          repository_slug: repo
        }
      end

      def collect_stash_project
        HighLine.ask("Project slug: ") do |q|
          q.whitespace = :strip
          q.case = :upcase
          q.validate = -> (slug) { slug.length > 0 }
          q.responses[:not_valid] = "Project slug is required"
        end
      end

      def collect_repo_name
        HighLine.ask("Repository: ") do |q|
          q.whitespace = :strip
          q.validate = -> (repo) { repo.length > 0 }
          q.responses[:not_valid] = "Repository is required"
        end
      end

      def collect_github_repo_info
        owner = collect_github_repo_owner
        repo = collect_repo_name

        {
          owner: owner,
          repository: repo
        }
      end

      def collect_github_repo_owner
        HighLine.ask("Owner: ") do |q|
          q.whitespace = :strip
          q.validate = -> (owner) { owner.length > 0 }
          q.responses[:not_valid] = "Owner is required"
        end
      end
    end
  end
end