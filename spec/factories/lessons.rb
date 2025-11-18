FactoryBot.define do
  factory :lesson do
    association :user
    sequence(:topic) { |n| "Topic #{n}" }
    level { 'beginner' }
    content { 'This is a short lesson content used for tests.' }
    metadata { { quiz: [] } }
  end
end
