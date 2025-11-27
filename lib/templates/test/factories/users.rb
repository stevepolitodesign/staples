FactoryBot.define do
  sequence(:user_factory_email) { "person-#{_1}@example.com" }

  factory :user do
    sequence(:email) { "user-#{_1}@example.com" }
    password { "s3kret" } # avoid 'password', since Chrome will render a security dialog

    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end
