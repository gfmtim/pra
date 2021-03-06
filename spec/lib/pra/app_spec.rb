require_relative "../../../lib/pra/app"

describe Pra::App do
  describe "#run" do
    it "builds the window system" do
      subject.stub(:spawn_pull_request_fetcher)
      window_system_double = double('window system', setup: nil, run_loop: nil)
      expect(Pra::WindowSystemFactory).to receive(:build).with('curses').and_return(window_system_double)
      subject.run
    end

    it "sets up the window system" do
      subject.stub(:spawn_pull_request_fetcher)
      window_system_double = double('window system', run_loop: nil)
      Pra::WindowSystemFactory.stub(:build).and_return(window_system_double)
      expect(window_system_double).to receive(:setup)
      subject.run
    end

    it "spawns the pull request fetcher thread" do
      window_system_double = double('window system', setup: nil, run_loop: nil)
      Pra::WindowSystemFactory.stub(:build).and_return(window_system_double)
      expect(subject).to receive(:spawn_pull_request_fetcher)
      subject.run
    end

    it "starts the window system run loop" do
      subject.stub(:spawn_pull_request_fetcher)
      window_system_double = double('window system', setup: nil, refresh_pull_requests: nil)
      Pra::WindowSystemFactory.stub(:build).and_return(window_system_double)
      expect(window_system_double).to receive(:run_loop)
      subject.run
    end
  end

  describe "#fetch_and_refresh_pull_requests" do
    let(:pull_request_one) { double }
    let(:pull_request_two) { double }
    let(:error) { double('error fetching pull requests', message: double('error message'), backtrace: double('backtrace')) }
    let(:good_source_one) { double('good pull source one', :pull_requests => [pull_request_one]) }
    let(:good_source_two) { double('good pull source two', :pull_requests => [pull_request_two])}
    let(:bad_source) { double('bad pull source') }
    let(:success_status_one) { Pra::PullRequestService::FetchStatus.success([pull_request_one]) }
    let(:success_status_two) { Pra::PullRequestService::FetchStatus.success([pull_request_two])}
    let(:error_status) { Pra::PullRequestService::FetchStatus.error(error) }
    let(:window_system_double) { double('window system', refresh_pull_requests: nil, fetch_failed: nil, fetching_pull_requests: nil) }

    before do
      allow(Kernel).to receive(:sleep)
      allow(Pra::PullRequestService).to receive(:fetch_pull_requests).
        and_yield(success_status_one).
        and_yield(error_status).
        and_yield(success_status_two)
      allow(Pra::ErrorLog).to receive(:log)
      subject.instance_variable_set(:@window_system, window_system_double)
    end

    it "notifies the window system it is starting to fetch pull requests" do
      expect(window_system_double).to receive(:fetching_pull_requests)
      subject.fetch_and_refresh_pull_requests
    end

    it "fetches the pull requests from all of the sources" do
      expect(Pra::PullRequestService).to receive(:fetch_pull_requests)
      subject.fetch_and_refresh_pull_requests
    end

    it "tells the window system to refresh with the fetched pull requests" do
      expect(window_system_double).to receive(:refresh_pull_requests).with([pull_request_one, pull_request_two])
      subject.fetch_and_refresh_pull_requests
    end

    it "tells the window system about failures" do
      expect(window_system_double).to receive(:fetch_failed)
      subject.fetch_and_refresh_pull_requests
    end

    it "logs the errors for pull sources that could not be fetched" do
      expect(Pra::ErrorLog).to receive(:log).with(error)
      subject.fetch_and_refresh_pull_requests
    end

    it "sleeps for the polling frequency" do
      window_system_double = double('window system', refresh_pull_requests: nil, fetching_pull_requests: nil)
      subject.instance_variable_set(:@window_system, window_system_double)
      Pra::PullRequestService.stub(:fetch_pull_requests)
      expect(Kernel).to receive(:sleep)
      subject.fetch_and_refresh_pull_requests
    end
  end
end
