FactoryBot.define do
  factory :user do
    email                 {Faker::Internet.email}
    first_name            {Faker::Name.first_name}
    last_name             {Faker::Name.last_name}
    password              {"123456789a"}
    # encrypted_password    {Devise::Encryptor.digest(User, '123456789a')}
  end
end