require 'rails_helper'

RSpec.describe GenerateLessonService do
  let(:lesson) { build(:lesson) }
  let(:service) { described_class.new(lesson) }

  describe '.call' do
    it 'delegates to new.call' do
      result = double('result')
      service_instance = instance_double(described_class)
      allow(described_class).to receive(:new).with(lesson).and_return(service_instance)
      allow(service_instance).to receive(:call).and_return(result)
      expect(described_class.call(lesson)).to eq(result)
    end
  end

  describe '#call' do
    context 'when lesson is invalid' do
      it 'returns an error struct' do
        lesson.topic = nil
        res = service.call
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
        response = { 'choices' => [{ 'message' => { 'content' => '' } }] }
        allow(service).to receive(:generate_ai_response).and_return(response)
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
        groq_response = { 'choices' => [{ 'message' => { 'content' => raw } }] }
        allow(groq).to receive(:generate_lesson).and_return(groq_response)
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
        ai_response = { 'choices' => [{ 'message' => { 'content' => raw } }] }
        allow(service).to receive(:generate_ai_response).and_return(ai_response)
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
