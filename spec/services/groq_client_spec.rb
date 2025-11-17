# spec/services/groq_client_spec.rb
require "rails_helper"
require "webmock/rspec"

RSpec.describe GroqClient do
  let(:api_key) { "test-api-key" }
  let(:client)  { described_class.new(api_key: api_key) }
  let(:url)     { "https://api.groq.com/openai/v1/chat/completions" }

  before do
    stub_request(:post, url)
      .with(
        headers: {
          "Authorization" => "Bearer #{api_key}",
          "Content-Type"  => "application/json"
        }
      )
      .to_return(
        status: 200,
        body: {
          lesson: "Sample lesson text",
          quiz: [
            { question: "What is Ruby?", options: [ "a", "b" ], answer: "a" }
          ]
        }.to_json
      )
  end

  it "returns lesson content" do
    result = client.generate_lesson(topic: "Ruby", level: "beginner")

    expect(result["lesson"]).to eq("Sample lesson text")
  end

  it "returns quiz data" do
    result = client.generate_lesson(topic: "Ruby", level: "beginner")

    expect(result["quiz"]).to be_an(Array)
    expect(result["quiz"].first["question"]).to eq("What is Ruby?")
  end

  it "handles JSON parsing errors" do
    # override stub with invalid JSON
    stub_request(:post, url).to_return(status: 200, body: "INVALID_JSON")

    result = client.generate_lesson(topic: "Ruby", level: "beginner")

    expect(result["error"]).to be_present
  end
end
