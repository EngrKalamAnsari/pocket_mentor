class AddIndexToLessonsTopic < ActiveRecord::Migration[8.0]
  def change
    add_index :lessons, :topic
  end
end
