require 'ostruct'
class GenerateLessonService
  attr_reader :lesson, :error

  def self.call(lesson)
    new(lesson).call
  end

  def initialize(lesson)
    @lesson = lesson
    @error = nil
    @groq = GroqClient.new
  end

  def call
    return handle_error(lesson.errors.full_messages.to_sentence) unless lesson.valid?

    parsed, error_message = attempt_parse_with_retries
    return handle_error(error_message) if parsed.nil?

    persist_result(parsed)
  end

  private

  attr_reader :groq

  def generate_ai_response
    groq.generate_lesson(
      topic: lesson.topic,
      level: lesson.level
    )
  end

  def handle_error(error)
    OpenStruct.new(success: false, lesson: lesson, error: error)
  end

  def extract_content(ai_response)
    ai_response.dig('choices', 0, 'message', 'content')
  end

  def parse_json(raw_text)
    JSON.parse(raw_text)
  rescue JSON::ParserError
    nil
  end

  def attempt_parse_with_retries
    attempts = 0
    error_message = nil
    while attempts < 3
      ai_response = generate_ai_response
      return [nil, ai_response['error']] if ai_response['error'].present?

      raw_text = extract_content(ai_response)
      return [nil, 'AI returned empty response.'] if raw_text.blank?

      parsed = parse_json(raw_text)
      return [parsed, nil] if parsed.present?

      error_message = 'AI returned invalid JSON. Try again.'
      attempts += 1
    end

    [nil, error_message]
  end

  def persist_result(parsed)
    lesson.content  = parsed['lesson']
    lesson.metadata = parsed['quiz']
    if lesson.save
      OpenStruct.new(success: true, lesson: lesson, error: nil)
    else
      handle_error(lesson.errors.full_messages.to_sentence)
    end
  end
end
