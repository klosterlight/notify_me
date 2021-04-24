FactoryBot.define do
  factory :user do
    email { "correoprueba@gmail.com" }
    password { "12345678" }
    name { "Gibran Abdul" }
  end

  trait :admin do
    after(:create) { |user| user.add_role(:admin) }
  end

  trait :customer do
    after(:create) { |user| user.add_role(:customer) }
  end

  trait :scoped_customer do
    transient do
      address { build(:address) }
    end

    after(:create) do |user, evaluator|
      user.add_role(:customer)
      user.add_role(:customer, evaluator.address)
    end
  end
end
