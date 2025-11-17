class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.references :user, null: false, foreign_key: true
      t.string :topic
      t.string :level
      t.text :content
      t.jsonb :metadata

      t.timestamps
    end
  end
end
