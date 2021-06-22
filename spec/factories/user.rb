FactoryBot.define do
  factory :user do
    email                 {"test@gmail.com"}
    first_name            {"Dulguun"}
    last_name             {"Tuguldur"}
    password              {"123456789a"}
  end
  factory :existing_user do
    email                 {"dwight@christiansen-rutherford.io"}
    password              {"123456789a"}
  end
end