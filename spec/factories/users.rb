FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    # Devise tracking
    sign_in_count { 0 }
    current_sign_in_at { nil }
    last_sign_in_at { nil }
    current_sign_in_ip { nil }
    last_sign_in_ip { nil }

    # Confirmable
    confirmation_token { nil }
    confirmed_at { Time.current }
    confirmation_sent_at { 1.hour.ago }
    unconfirmed_email { nil }

    # Lockable
    failed_attempts { 0 }
    unlock_token { nil }
    locked_at { nil }
  end
end
