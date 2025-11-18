class GroqClient
  GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions'.freeze

  # Accepts an explicit API key and model, or falls back to ENV values.
  def initialize(api_key: ENV.fetch('GROQ_API_KEY', nil), model: ENV.fetch('GROQ_MODEL', 'llama-3.1-8b-instant'))
    @api_key = api_key
    @model = model
    @client = Faraday.new(url: GROQ_URL)
  end

  def generate_lesson(topic:, level:)
    return { 'error' => 'GROQ_API_KEY is not configured' } if @api_key.blank?

    topic = sanitize_text(topic)
    level = sanitize_level(level)

    prompt = build_prompt(topic, level)
    response = send_request(prompt)

    parse_response(response)
  rescue StandardError => e
    { 'error' => e.message }
  end

  private

  def build_prompt(topic, level)
    <<~PROMPT
      Create a micro lesson on "#{topic}" for a #{level} learner.

      Respond in valid JSON only:

      {
        "lesson": "text...",
        "quiz": [
          { "question": "...", "options": ["a","b","c","d"], "answer": "a" }
        ]
      }
    PROMPT
  end

  # Basic input sanitization to reduce prompt-injection risk.
  # Removes control chars, HTML tags, trims length, and collapses whitespace.
  def sanitize_text(value)
    return '' if value.nil?

    s = value.to_s
    # Remove control characters
    s = s.gsub(/[\u0000-\u001f\u007f]/, '')
    # Use Rails' sanitizer to strip dangerous HTML
    s = if defined?(ActionView::Base)
          ActionView::Base.full_sanitizer.sanitize(s)
        else
          s.gsub(/<[^>]*>/, '')
        end
    # Collapse whitespace and strip
    s = s.gsub(/\s+/, ' ').strip
    # Remove problematic quote/backtick characters
    s = s.tr('"\'"`', '')
    # Limit length
    s[0, 200]
  end

  # Restrict level to a small set of allowed values, fallback to 'beginner'
  def sanitize_level(value)
    allowed = Lesson::LEVELS
    v = value.to_s.downcase.strip
    allowed.include?(v) ? v : 'beginner'
  end

  def send_request(prompt)
    @client.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{@api_key}"

      req.body = {
        model: @model,
        messages: [
          { role: 'user', content: prompt }
        ],
        temperature: 0.7
      }.to_json
    end
  end

  def parse_response(response)
    JSON.parse(response.body)
  end
end
