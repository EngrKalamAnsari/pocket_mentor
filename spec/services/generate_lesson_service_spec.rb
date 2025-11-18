require 'rails_helper'

RSpec.describe GenerateLessonService do
  let(:lesson) { build(:lesson) }
  subject { described_class.new(lesson) }

  describe '.call' do
    it 'delegates to new.call' do
      expect_any_instance_of(described_class).to receive(:call).and_return(:ok)
      expect(described_class.call(lesson)).to eq(:ok)
    end
  end

  describe '#call' do
    context 'when lesson is invalid' do
      it 'returns an error struct' do
        lesson.topic = nil
        res = subject.call
        expect(res.success).to be false
        expect(res.error).to be_present
      end
    end

    context 'when groq returns an error' do
      it 'returns that error' do
        service = described_class.new(lesson)
        allow(service).to receive(:generate_ai_response).and_return({ 'error' => 'rate limited' })
        res = service.call
        expect(res.success).to be false
        expect(res.error).to eq('rate limited')
      end
    end

    context 'when groq returns blank content' do
      it 'returns AI returned empty response' do
        service = described_class.new(lesson)
        allow(service).to receive(:generate_ai_response).and_return({ 'choices' => [{ 'message' => { 'content' => '' } }] })
        res = service.call
        expect(res.success).to be false
        expect(res.error).to eq('AI returned empty response.')
      end
    end

    context 'when groq returns invalid JSON multiple times' do
      it 'retries and then returns invalid JSON error' do
        service = described_class.new(lesson)
        # return choices with invalid json content three times
        allow(service).to receive(:generate_ai_response).and_return(
          { 'choices' => [{ 'message' => { 'content' => 'not json' } }] }
        )
        res = service.call
        expect(res.success).to be false
        expect(res.error).to eq('AI returned invalid JSON. Try again.')
      end
    end

    context 'when parsed JSON is returned and lesson saves' do
      it 'persists content and metadata and returns success' do
        service = described_class.new(lesson)
        parsed = { 'lesson' => 'L', 'quiz' => [{ 'q' => 1 }] }
        raw = parsed.to_json
        # Inject a groq double so the generate_lesson call is exercised
        groq = double('groq')
        allow(groq).to receive(:generate_lesson).and_return({ 'choices' => [{ 'message' => { 'content' => raw } }] })
        service.instance_variable_set(:@groq, groq)
        res = service.call
        expect(res.success).to be true
        expect(res.lesson.content).to eq('L')
        expect(res.lesson.metadata).to eq([{ 'q' => 1 }])
      end
    end

    context 'when parsed JSON but save fails' do
      it 'returns an error from lesson.save' do
        lesson_to_fail = build(:lesson)
        service = described_class.new(lesson_to_fail)
        parsed = { 'lesson' => 'L', 'quiz' => [{ 'q' => 1 }] }
        raw = parsed.to_json
        allow(service).to receive(:generate_ai_response).and_return({ 'choices' => [{ 'message' => { 'content' => raw } }] })
        # When save is called, add an error and return false so the service reads it
        errors = ActiveModel::Errors.new(lesson_to_fail)
        allow(lesson_to_fail).to receive(:errors).and_return(errors)
        allow(lesson_to_fail).to receive(:save) do
          errors.add(:base, 'save failed')
          false
        end
        res = service.call
        expect(res.success).to be false
        expect(res.error).to eq('save failed')
      end
    end
  end
end
