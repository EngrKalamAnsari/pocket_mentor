class Lesson < ApplicationRecord
Levels = %w[beginner intermediate advanced].freeze

  belongs_to :user

  validates :topic, :level, presence: true
  validates :topic, length: { maximum: 150 }
  validates :level, inclusion: { in: Levels }
end
