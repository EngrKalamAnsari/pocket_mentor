class EnsureIndexOnLessonsCreatedAt < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    unless index_exists?(:lessons, :created_at)
      add_index :lessons, :created_at, algorithm: :concurrently
    end
  end

  def down
    if index_exists?(:lessons, :created_at)
      remove_index :lessons, :created_at, algorithm: :concurrently
    end
  end
end
