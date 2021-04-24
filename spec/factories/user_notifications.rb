FactoryBot.define do
  factory :user_notification do
    user
    notification
    is_read { false }
    read_at { nil }
  end
end
