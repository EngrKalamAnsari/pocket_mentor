class Lesson < ApplicationRecord
  LEVELS = %w[beginner intermediate advanced].freeze

  belongs_to :user

  validates :topic, :level, presence: true
  validates :topic, length: { maximum: 150 }
  validates :level, inclusion: { in: LEVELS }
end
