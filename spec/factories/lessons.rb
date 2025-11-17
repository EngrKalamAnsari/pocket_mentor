FactoryBot.define do
  factory :lesson do
    user { nil }
    topic { "MyString" }
    level { "MyString" }
    content { "MyText" }
    metadata { "" }
  end
end
