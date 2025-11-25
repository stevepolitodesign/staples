# frozen_string_literal: true

RSpec.describe Staples do
  it "has a version number" do
    expect(Staples::VERSION).not_to be nil
  end

  describe Staples::CLI do
    let(:stub_success) {
      allow_any_instance_of(Staples::CLI).to receive(:system).and_return(true)
    }

    before do
      stub_success
    end

    describe ".run" do
      it "calls rails new with expected arguments" do
        args = [
          "rails",
          "new",
          "app_name",
          "-d=postgresql",
          "--css=bootstrap",
          "--skip-solid"
        ]

        expect_any_instance_of(Staples::CLI).to receive(:system).with(*args)

        Staples::CLI.run("app_name")
      end

      it "returns true" do
        result = Staples::CLI.run("app_name")

        expect(result).to eq true
      end

      context "when rails does not exist" do
        let(:stub_failure) {
          allow_any_instance_of(Staples::CLI).to receive(:system).with(
            "which", "rails", out: File::NULL, err: File::NULL
          ).and_return(false)
        }

        before do
          stub_failure
        end

        it "raises" do
          expect {
            Staples::CLI.run("app_name")
          }.to raise_error(Staples::Error, "Rails not found. Install with: gem install rails")
        end
      end

      context "when rails fails to install" do
        let(:app_name) { "app_name" }
        let(:args) {
          [
            "rails",
            "new",
            app_name,
            "-d=postgresql",
            "--css=bootstrap",
            "--skip-solid"
          ]
        }
        let(:stub_failure) {
          allow_any_instance_of(Staples::CLI).to receive(:system).with(*args).and_return(false)
        }

        before do
          stub_failure
        end

        it "raises" do
          expect {
            Staples::CLI.run(app_name)
          }.to raise_error(Staples::Error, "Failed to create Rails app")
        end
      end
    end
  end
end
