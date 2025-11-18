require 'rails_helper'
require 'ostruct'

RSpec.describe LessonsController, type: :controller do
  let(:user) { create(:user) }
  before { allow(controller).to receive(:authenticate_user!).and_return(true); allow(controller).to receive(:current_user).and_return(user) }

  describe 'GET index' do
    it 'assigns lessons for current user ordered by created_at desc' do
      l1 = create(:lesson, user: user, created_at: 1.day.ago)
      l2 = create(:lesson, user: user, created_at: 1.hour.ago)
      get :index
      expect(controller.instance_variable_get(:@lessons)).to eq([l2, l1])
    end
  end

  describe 'GET new' do
    it 'assigns a new lesson' do
      get :new
      expect(controller.instance_variable_get(:@lesson)).to be_a_new(Lesson)
    end
  end

  describe 'POST create' do
    let(:valid_params) { { lesson: { topic: 'T', level: 'beginner' } } }

    context 'when service succeeds' do
      it 'redirects to the lesson with notice' do
        lesson = build(:lesson)
        result = OpenStruct.new(success: true, lesson: lesson, error: nil)
        allow(GenerateLessonService).to receive(:call).and_return(result)
        allow(user.lessons).to receive(:build).and_return(lesson)
        allow(lesson).to receive(:save).and_return(true)
        post :create, params: valid_params
        expect(flash[:notice]).to eq('Lesson generated successfully.')
      end
    end

    context 'when service returns error' do
      it 'renders new with alert' do
        lesson = build(:lesson)
        result = OpenStruct.new(success: false, lesson: lesson, error: 'boom')
        allow(GenerateLessonService).to receive(:call).and_return(result)
        allow(user.lessons).to receive(:build).and_return(lesson)
        post :create, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:alert]).to eq('boom')
      end
    end
  end

  describe 'set_lesson rescue' do
    it 'redirects to lessons_path with alert if not found' do
      allow(user.lessons).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(id: 1))
      controller.instance_variable_set(:@_response, response)
      controller.send(:set_lesson)
      expect(response).to redirect_to(lessons_path)
      expect(flash[:alert]).to eq('Lesson not found.')
    end
  end
end
