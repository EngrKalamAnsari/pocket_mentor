class LessonsController < ApplicationController
  load_and_authorize_resource

  def index
    @lessons = current_user.lessons.order(created_at: :desc)
  end

  def show; end

  def new
    @lesson = Lesson.new
  end

  def create
    @lesson = current_user.lessons.build(lesson_params)
    result = GenerateLessonService.call(@lesson)
    @lesson = result.lesson
    if result.success
      handle_create_success(@lesson)
    else
      handle_create_error(@lesson, result.error)
    end
  end

  private

  def handle_create_success(lesson)
    flash[:notice] = 'Lesson generated successfully.'
    redirect_to lesson
  end

  def handle_create_error(_lesson, error)
    flash.now[:alert] = error.presence || 'Failed to save lesson.'
    render :new, status: :unprocessable_entity
  end

  def set_lesson
    @lesson = current_user.lessons.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to lessons_path, alert: 'Lesson not found.'
  end

  def lesson_params
    params.require(:lesson).permit(:topic, :level)
  end
end
