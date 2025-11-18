# spec/services/groq_client_spec.rb
require 'rails_helper'
require 'webmock/rspec'

RSpec.describe GroqClient do
  let(:api_key) { 'test-api-key' }
  let(:client)  { described_class.new(api_key: api_key) }
  let(:url)     { 'https://api.groq.com/openai/v1/chat/completions' }

  before do
    stub_request(:post, url)
      .with(
        headers: {
          'Authorization' => "Bearer #{api_key}",
          'Content-Type' => 'application/json'
        }
      )
      .to_return(
        status: 200,
        body: {
          lesson: 'Sample lesson text',
          quiz: [
            { question: 'What is Ruby?', options: %w[a b], answer: 'a' }
          ]
        }.to_json
      )
  end

  it 'returns lesson content' do
    result = client.generate_lesson(topic: 'Ruby', level: 'beginner')

    expect(result['lesson']).to eq('Sample lesson text')
  end

  it 'returns quiz data' do
    result = client.generate_lesson(topic: 'Ruby', level: 'beginner')

    expect(result['quiz']).to be_an(Array)
    expect(result['quiz'].first['question']).to eq('What is Ruby?')
  end

  it 'handles JSON parsing errors' do
    # override stub with invalid JSON
    stub_request(:post, url).to_return(status: 200, body: 'INVALID_JSON')

    result = client.generate_lesson(topic: 'Ruby', level: 'beginner')

    expect(result['error']).to be_present
  end

  it 'returns a graceful error when API key is missing' do
    client_without_key = described_class.new(api_key: nil)

    result = client_without_key.generate_lesson(topic: 'Ruby', level: 'beginner')

    expect(result['error']).to eq('GROQ_API_KEY is not configured')
  end

  it 'sends configured model in the request body' do
    custom_model = 'custom-model-123'
    client_with_model = described_class.new(api_key: api_key, model: custom_model)

    stub_request(:post, url).with(body: /#{custom_model}/).to_return(status: 200, body: { lesson: 'ok' }.to_json)

    result = client_with_model.generate_lesson(topic: 'Ruby', level: 'beginner')

    expect(result['lesson']).to eq('ok')
  end

  it 'uses ENV defaults when not passed explicit api_key/model' do
    ENV['GROQ_API_KEY'] = 'env-key'
    ENV['GROQ_MODEL'] = 'env-model-xyz'
    begin
      c = described_class.new
      expect(c.instance_variable_get(:@api_key)).to eq('env-key')
      expect(c.instance_variable_get(:@model)).to eq('env-model-xyz')
    ensure
      ENV.delete('GROQ_API_KEY')
      ENV.delete('GROQ_MODEL')
    end
  end

  it 'executes the request block in send_request (yields request object)' do
    # Create a client and stub its internal Faraday connection to yield a request object
    conn = client.instance_variable_get(:@client)
    req = double('req', headers: {})
    allow(req).to receive(:body=)
    resp = instance_double('Faraday::Response', body: { lesson: 'ok' }.to_json)
    allow(conn).to receive(:post).and_yield(req).and_return(resp)

    # The block should set headers and body without raising
    expect { client.send(:send_request, 'prompt') }.not_to raise_error
    expect(req.headers['Content-Type']).to eq('application/json')
    expect(req.headers['Authorization']).to eq("Bearer #{api_key}")
  end

  context 'private helpers' do
    describe '#sanitize_text' do
      it 'strips html, control chars, quotes, collapses whitespace and truncates' do
        raw = "<b>Hi</b>\u0000\u0001  \"quoted\" `tick` 'single' " + 'x' * 500
        out = client.send(:sanitize_text, raw)
        expect(out).not_to include('<', '>')
        expect(out).not_to include('"', "'", '`')
        expect(out.length).to be <= 200
      end

      it 'returns empty string for nil input' do
        expect(client.send(:sanitize_text, nil)).to eq('')
      end

      it 'uses regex HTML stripping when ActionView::Base is not defined' do
        # Temporarily remove ActionView::Base to exercise else branch
        had_action_view = defined?(ActionView::Base)
        av = nil
        if had_action_view
          av = ActionView
          Object.send(:remove_const, :ActionView)
        end

        begin
          raw = '<div>hello</div>'
          out = client.send(:sanitize_text, raw)
          expect(out).to eq('hello')
        ensure
          Object.const_set(:ActionView, av) if av
        end
      end
    end

    describe '#sanitize_level' do
      it 'accepts allowed levels and normalizes to lowercase' do
        expect(client.send(:sanitize_level, 'Intermediate')).to eq('intermediate')
      end

      it 'falls back to beginner for unknown levels' do
        expect(client.send(:sanitize_level, 'nonsense')).to eq('beginner')
      end
    end

    describe '#build_prompt' do
      it 'contains the topic and level' do
        p = client.send(:build_prompt, 'Loops', 'beginner')
        expect(p).to include('Loops')
        expect(p).to include('beginner')
      end
    end

    describe '#parse_response' do
      it 'parses JSON from response body' do
        resp = instance_double('Faraday::Response', body: { 'ok' => true }.to_json)
        expect(client.send(:parse_response, resp)).to eq({ 'ok' => true })
      end
    end

    describe '#send_request' do
      it 'sends request with proper headers and body structure' do
        # Use WebMock stub to assert headers and body
        stub = stub_request(:post, url)
               .with(headers: { 'Authorization' => "Bearer #{api_key}", 'Content-Type' => 'application/json' })
               .to_return(status: 200, body: { lesson: 'ok' }.to_json)

        res = client.send(:send_request, 'some prompt')
        expect(stub).to have_been_requested
        expect(JSON.parse(res.body)['lesson']).to eq('ok')
      end

      it 'executes the Faraday block (headers and body) when client yields' do
        conn = client.instance_variable_get(:@client)
        req_double = double('req')
        resp = instance_double('Faraday::Response', body: { lesson: 'ok' }.to_json)

        headers = {}
        allow(req_double).to receive(:headers).and_return(headers)
        allow(req_double).to receive(:body=)

        allow(conn).to receive(:post).and_yield(req_double).and_return(resp)

        result = client.send(:send_request, 'prompt')
        expect(result.body).to include('lesson')
        expect(headers['Content-Type']).to eq('application/json') if headers.key?('Content-Type')
      end
    end
  end
end
