require_relative "../../../lib/pra/config"
require 'fakefs/spec_helpers'

describe Pra::Config do
  describe "#initialize" do
    it "assigns the provide default config hash" do
      config_hash = { some: "hash" }
      config = Pra::Config.new(config_hash)
      config.instance_variable_get(:@initial_config).should eq(config_hash)
    end
  end

  describe ".load_config" do
    subject { Pra::Config }

    it "parses the config file" do
      subject.should_receive(:parse_config_file)
      subject.load_config
    end

    it "constructs an instance of the config from the parsed config" do
      parsed_config = double('parsed config file')
      subject.stub(:parse_config_file).and_return(parsed_config)
      subject.should_receive(:new).with(parsed_config)
      subject.load_config
    end

    it "returns the instance of the config object" do
      subject.stub(:parse_config_file)
      config = double('config')
      subject.stub(:new).and_return(config)
      subject.load_config.should eq(config)
    end
  end

  describe '.load_config_or_default' do
    subject { Pra::Config }

    context 'when the config file exists' do
      before { allow(subject).to receive(:config_exists?).and_return(true) }

      it 'loads the config' do
        expect(subject).to receive(:load_config)
        subject.load_config_or_default
      end
    end

    context 'when the config file does not exist' do
      before { allow(subject).to receive(:config_exists?).and_return(false) }

      it 'builds a default config' do
        expect(subject).to receive(:new).with({'pull_sources' => []})
        subject.load_config_or_default
      end
    end
  end

  describe ".config_exists?" do
    include FakeFS::SpecHelpers
    subject { Pra::Config }

    context "when the config file exists" do
      before do
        FileUtils.mkdir_p(File.dirname(subject.config_path))
        File.write(subject.config_path, '{}')
      end

      it 'returns true' do
        expect(subject.config_exists?).to be_true
      end
    end

    context 'when the config file does not exist' do
      it 'returns false' do
        expect(subject.config_exists?).to be_false
      end
    end
  end

  describe ".write_config_file" do
    include FakeFS::SpecHelpers
    subject { Pra::Config }

    before do
      FileUtils.mkdir_p(File.dirname(subject.config_path))
    end

    context "when a config file exists" do
      before do
        File.write(subject.config_path, 'old config')
      end

      it "backs up the config" do
        subject.write_config_file({})
        expect(File.read(subject.config_path + '.bak')).to eq('old config')
      end
    end

    context "when a config file does not exist" do
      it "does not create a backup file" do
        subject.write_config_file({})
        expect(File.exists?(subject.config_path + '.bak')).to be_false
      end
    end

    it "writes the new config to the config file" do
      new_config = {'pull_sources' => [{'type' => 'github', 'repositories' => []}]}
      subject.write_config_file(new_config)
      config = File.read(subject.config_path)
      expect(JSON.parse(config)).to eq(new_config)
    end
  end

  describe ".parse_config_file" do
    subject { Pra::Config }

    it "reads the users config" do
      subject.stub(:json_parse)
      subject.should_receive(:read_config_file)
      subject.parse_config_file
    end

    it "json parses the config contents" do
      config_contents = double('config contents')
      subject.stub(:read_config_file).and_return(config_contents)
      subject.should_receive(:json_parse).with(config_contents)
      subject.parse_config_file
    end
  end

  describe ".read_config_file" do
    subject { Pra::Config }

    it "opens the file" do
      config_path = double('config path')
      subject.stub(:config_path).and_return(config_path)
      File.should_receive(:open).with(config_path, "r").and_return(double('config file').as_null_object)
      subject.read_config_file
    end

    it "reads the files contents" do
      subject.stub(:config_path)
      file = double('config file').as_null_object
      File.stub(:open).and_return(file)
      file.should_receive(:read)
      subject.read_config_file
    end

    it "closes the file" do
      subject.stub(:config_path)
      file = double('config file', read: nil)
      File.stub(:open).and_return(file)
      file.should_receive(:close)
      subject.read_config_file
    end

    it "returns the file contents" do
      subject.stub(:config_path)
      file = double('config file', close: nil)
      File.stub(:open).and_return(file)
      file.stub(:read).and_return('some file contents')
      subject.read_config_file.should eq('some file contents')
    end
  end

  describe ".config_path" do
    subject { Pra::Config }

    it "returns the joined users home directory and .pra.json to create the path" do
      subject.stub(:users_home_directory).and_return('/home/someuser')
      subject.config_path.should eq('/home/someuser/.pra.json')
    end
  end

  describe ".error_log_path" do
    subject { Pra::Config }

    it "returns the joined users home directory and .pra.error.log to create the path" do
      allow(subject).to receive(:users_home_directory).and_return('/home/someuser')
      expect(subject.error_log_path).to eq('/home/someuser/.pra.errors.log')
    end
  end

  describe ".users_home_directory" do
    subject { Pra::Config }

    it "returns the current users home directory" do
      ENV['HOME'] = '/home/someuser'
      subject.users_home_directory.should eq('/home/someuser')
    end
  end

  describe ".json_parse" do
    subject { Pra::Config }

    it "parses the given content as json" do
      content = double('some json content')
      JSON.should_receive(:parse).with(content)
      subject.json_parse(content)
    end

    it "returns the parsed result" do
      parsed_json = double('the parsed json')
      JSON.stub(:parse).and_return(parsed_json)
      subject.json_parse(double).should eq(parsed_json)
    end
  end

  describe "#pull_sources" do
    it "returns the pull sources value out of the config" do
      pull_source_configs = double('pull source configs')
      subject.instance_variable_set(:@initial_config, { "pull_sources" => pull_source_configs })
      subject.pull_sources.should eq(pull_source_configs)
    end
  end

  describe "#assignee_blacklist" do
    it "returns the assignee blacklist value out of the config" do
      assignee_blacklist_configs = double('assignee blacklist configs')
      subject.instance_variable_set(:@initial_config, { "assignee_blacklist" => assignee_blacklist_configs })
      subject.assignee_blacklist.should eq(assignee_blacklist_configs)
    end
  end

  describe "#add_pull_source" do
    subject { Pra::Config.new({'pull_sources' => []}) }

    it 'adds the source to the pull sources array' do
      source = double
      subject.add_pull_source(source)
      expect(subject.pull_sources).to include(source)
    end
  end
end
