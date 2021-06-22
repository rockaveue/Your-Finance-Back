FactoryBot.define do
  factory :transaction do
    is_income             {false}
    amount                {100}
    transaction_date      {"2021-06-18"}
    is_repeat             {false}
    note                  {"testtest"}
  end
end