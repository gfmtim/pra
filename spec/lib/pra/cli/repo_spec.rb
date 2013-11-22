require_relative '../../../../lib/pra/cli/repo'
require 'highline/simulate'

describe Pra::Cli::Repo do
  describe '#add' do
    let(:pra_config) { double('Pra::Config') }

    before do
      allow(Pra::Config).to receive(:load_config_or_default) { pra_config }
      allow(pra_config).to receive(:write_config)
    end

    context 'when there are no pull sources' do
      before { allow(pra_config).to receive(:pull_sources).and_return([]) }

      it 'prints an error message' do
        expect(HighLine).to receive(:say).with("You'll need to add a pull source with `pra source add` first.")
        subject.add
      end
    end

    context 'when there are pull sources' do
      let(:source_1) { double }
      let(:source_2) { double }

      before do
        allow(pra_config).to receive(:pull_sources).and_return([source_1, source_2])
      end

      it 'prompts the user to choose a pull source' do
        expect(subject).to receive(:pick_source).with([source_1, source_2]).and_return(double.as_null_object)
        subject.add
      end

      it 'gets the repo information' do
        source = double(:[] => {})
        allow(subject).to receive(:pick_source).and_return(source)
        expect(subject).to receive(:collect_repo_info).with(source)
        subject.add
      end

      it 'adds the repo to the pull source' do
        source = double# {'config' => {'repositories' => repos}}
        repo = double
        allow(subject).to receive(:pick_source).and_return(source)
        allow(subject).to receive(:collect_repo_info).and_return(repo)
        expect(subject).to receive(:add_repo_to_source).with(source, repo)
        subject.add
      end

      it 'writes the config' do
        allow(subject).to receive(:pick_source)
        allow(subject).to receive(:collect_repo_info)
        allow(subject).to receive(:add_repo_to_source)
        expect(pra_config).to receive(:write_config)
        subject.add
      end
    end
  end

  describe '#pick_source' do
    it 'returns the selected source' do
      sources = [
        { 'type' => 'github', 'config' => {'host' => 'api.github.com'} },
        { 'type' => 'stash', 'config' => {'host' => 'stash.atlassian.com'} }
      ]

      HighLine::Simulate.with('2') do
        expect(subject.send(:pick_source, sources)).to eq(sources.last)
      end
    end
  end

  describe '#collect_repo_info' do
    let(:github_repo) { double }
    let(:stash_repo) { double }

    before do
      allow(subject).to receive(:collect_github_repo_info) { github_repo }
      allow(subject).to receive(:collect_stash_repo_info) { stash_repo }
    end

    context 'when the source type is github' do
      let(:source) { {'type' => 'github'} }

      it 'gets info for a github repo' do
        expect(subject).to receive(:collect_github_repo_info)
        subject.send(:collect_repo_info, source)
      end

      it 'returns the repo info' do
        expect(subject.send(:collect_repo_info, source)).to eq(github_repo)
      end
    end

    context 'when the source type is stash' do
      let(:source) { {'type' => 'stash'} }

      it 'gets info for a stash repo' do
        expect(subject).to receive(:collect_stash_repo_info)
        subject.send(:collect_repo_info, source)
      end

      it 'returns the repo info' do
        expect(subject.send(:collect_repo_info, source)).to eq(stash_repo)
      end
    end
  end

  describe '#collect_stash_repo_info' do
    let(:project) { double }
    let(:repo) { double }

    before do
      allow(subject).to receive(:collect_stash_project) { project }
      allow(subject).to receive(:collect_repo_name) { repo }
    end

    it 'returns a hash with the repo info' do
      expect(subject.send(:collect_stash_repo_info)).to eq({project_slug: project, repository_slug: repo})
    end
  end

  describe '#collect_github_repo_info' do
    let(:owner) { double }
    let(:repo) { double }

    before do
      allow(subject).to receive(:collect_github_repo_owner) { owner }
      allow(subject).to receive(:collect_repo_name) { repo }
    end

    it 'returns a hash with the repo info' do
      expect(subject.send(:collect_github_repo_info)).to eq({owner: owner, repository: repo})
    end
  end

  describe '#collect_stash_project' do
    it 'returns the project slug' do
      HighLine::Simulate.with("CAP") do
        expect(subject.send(:collect_stash_project)).to eq('CAP')
      end
    end

    it 'upcases the project slug' do
      HighLine::Simulate.with('cap') do
        expect(subject.send(:collect_stash_project)).to eq('CAP')
      end
    end
  end

  describe '#add_repo_to_source' do
    let(:repo) { double }
    let(:source) { {'config' => {'repositories' => [double]}} }

    it 'adds the repo to the source' do
      subject.send(:add_repo_to_source, source, repo)
      expect(source['config']['repositories']).to include(repo)
    end
  end

  describe '#collect_repo_name' do
    it 'returns the repo' do
      HighLine::Simulate.with('pra') do
        expect(subject.send(:collect_repo_name)).to eq('pra')
      end
    end

    it 'requires a name' do
      HighLine::Simulate.with('', '   ', 'pra') do
        expect(subject.send(:collect_repo_name)).to eq('pra')
      end
    end
  end

  describe '#collect_github_repo_owner' do
    it 'returns the owner' do
      HighLine::Simulate.with('reachlocal') do
        expect(subject.send(:collect_github_repo_owner)).to eq('reachlocal')
      end
    end

    it 'requires an owner' do
      HighLine::Simulate.with('', '   ', 'reachlocal') do
        expect(subject.send(:collect_github_repo_owner)).to eq('reachlocal')
      end
    end
  end
end