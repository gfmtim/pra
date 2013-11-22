require_relative '../../../../lib/pra/cli/source'
require 'highline/simulate'
require 'fakefs/safe'

describe Pra::Cli::Source do
  before { FakeFS.activate! }

  after { FakeFS.deactivate! }

  describe '#add' do
    let(:config) { double('Pra::Config') }

    before do
      allow(config).to receive(:write_config)
      allow(config).to receive(:add_pull_source)
      allow(Pra::Config).to receive(:load_config_or_default).and_return(config)
    end

    it 'gets the pull source data' do
      type = double
      expect(subject).to receive(:build_pull_source).with(type)
      subject.add(type)
    end

    it 'loads the pra config' do
      allow(subject).to receive(:build_pull_source)
      expect(Pra::Config).to receive(:load_config_or_default)
      subject.add
    end

    it 'adds the pull source to the config' do
      source = double
      allow(subject).to receive(:build_pull_source).and_return(source)
      expect(config).to receive(:add_pull_source).with(source)
      subject.add
    end

    it 'writes the updated config' do
      expect(config).to receive(:write_config)
      allow(subject).to receive(:build_pull_source)
      subject.add
    end
  end

  describe '#build_pull_source' do
    let(:type) { double }
    let(:host) { double }
    let(:protocol) { double }
    let(:username) { double }
    let(:password) { double }

    before do
      allow(subject).to receive(:collect_source_type) { type }
      allow(subject).to receive(:collect_host) { host }
      allow(subject).to receive(:collect_protocol) { protocol }
      allow(subject).to receive(:collect_username) { username }
      allow(subject).to receive(:collect_password) { password }
    end

    it 'asks for the source info' do
      passed_type = double
      expect(subject).to receive(:collect_source_type).with(passed_type)
      expect(subject).to receive(:collect_host)
      expect(subject).to receive(:collect_protocol)
      expect(subject).to receive(:collect_username)
      expect(subject).to receive(:collect_password)
      subject.send(:build_pull_source, passed_type)
    end

    it 'builds a hash for the pull source' do
      source = subject.send(:build_pull_source, double)
      expect(source).to eq({
        type: type,
        config: {
          host: host,
          protocol: protocol,
          username: username,
          password: password,
          repositories: []
        }  
      })
    end
  end

  describe '#collect_source_type' do
    context 'when passed a valid source type' do
      it 'prints a message' do
        expect(HighLine).to receive(:say).with("Adding a github pull source")
        subject.send(:collect_source_type, 'github')
      end

      it 'returns the source type' do
        expect(subject.send(:collect_source_type, 'github')).to eq('github')
      end
    end

    context 'when not passed a valid source type' do
      it 'waits for a valid source type to be selected' do
        HighLine::Simulate.with('source_safe', 'cvshub', 'stash') do
          expect(subject.send(:collect_source_type, nil)).to eq('stash')
        end
      end
    end
  end

  describe '#collect_host' do
    context 'when the source type is github' do
      it 'defaults to api.github.com' do
        HighLine::Simulate.with("\n") do
          host = subject.send(:collect_host, 'github')
          expect(host).to eq('api.github.com')
        end
      end

      it 'allows custom github hosts' do
        HighLine::Simulate.with("github.reachlocal.com") do
          host = subject.send(:collect_host, 'github')
          expect(host).to eq('github.reachlocal.com')
        end
      end
    end

    context 'when the source type is stash' do
      it 'does not have a default' do
        HighLine::Simulate.with("\n", "stash.atlassian.com") do
          expect(subject.send(:collect_host, 'stash')).to eq('stash.atlassian.com')
        end
      end
    end
  end

  describe '#collect_protocol' do
    it 'defaults to https' do
      HighLine::Simulate.with("\n") do
        protocol = subject.send(:collect_protocol)
        expect(protocol).to eq('https')
      end
    end

    context 'when user answers yes' do
      it 'returns https' do
        HighLine::Simulate.with('y') do
          protocol = subject.send(:collect_protocol)
          expect(protocol).to eq('https')
        end
      end
    end

    context 'when user answers no' do
      it 'returns http' do
        HighLine::Simulate.with('n') do
          protocol = subject.send(:collect_protocol)
          expect(protocol).to eq('http')
        end
      end
    end
  end

  describe '#collect_username' do
    it 'returns the username' do
      HighLine::Simulate.with('', 'username') do
        expect(subject.send(:collect_username)).to eq('username')
      end
    end
  end

  describe '#collect_password' do
    it 'returns the password' do
      HighLine::Simulate.with('', 'password') do
        expect(subject.send(:collect_password)).to eq('password')
      end
    end
  end
end