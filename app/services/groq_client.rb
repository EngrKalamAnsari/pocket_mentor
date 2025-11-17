class GroqClient
  GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"

  def initialize(api_key: ENV["GROQ_API_KEY"])
    @api_key = api_key
    @client = Faraday.new(url: GROQ_URL)
  end

  def generate_lesson(topic:, level:)
    prompt = <<~PROMPT
      Create a micro lesson on "#{topic}" for a #{level} learner.

      Respond in valid JSON only:

      {
        "lesson": "text...",
        "quiz": [
          { "question": "...", "options": ["a","b","c","d"], "answer": "a" }
        ]
      }
    PROMPT

    response = @client.post do |req|
      req.headers["Content-Type"] = "application/json"
      req.headers["Authorization"] = "Bearer #{@api_key}"

      req.body = {
        model: "llama-3.1-8b-instant",  # ✅ supported model
        messages: [
          { role: "user", content: prompt }
        ],
        temperature: 0.7
      }.to_json
    end

    JSON.parse(response.body)
  rescue => e
    { "error" => e.message }
  end
end
