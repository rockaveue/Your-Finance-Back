# User seeder
# 5.times do
#     User.create!({
#         email: Faker::Internet.email,
#         password: '123456789a',
#         encrypted_password: Devise::Encryptor.digest(User, '123456789a'),
#         first_name: Faker::Name.first_name,
#         last_name: Faker::Name.last_name,
#         balance: Faker::Number.number(digits: 6)
#     })
# end

# ---------------------------------------------
# Category seeder
# 10.times do
#   Category.create({
#     category_name: Faker::JapaneseMedia::OnePiece.location,
#     is_income: Faker::Number.between(from: 0, to: 1),
#     is_default: Faker::Number.between(from: 0, to: 1)
#   })
# end
# # ---------------------------------------------
# # # Transaction seeder
# 10.times do
#   Transaction.create!({
#     category_id: Faker::Number.between(from:101, to: 110),
#     user_id: Faker::Number.between(from:501, to: 505),
#     is_income: Faker::Boolean.boolean,
#     transaction_date: Faker::Date.between(from: 1.year.ago, to: Date.today),
#     amount: Faker::Number.between(from: 0, to: 1000000, ),
#     is_repeat: Faker::Boolean.boolean,
#     note: Faker::Lorem.sentence(word_count: 3)
#   })
# end
# User Category seeder
# (1..10).each do |j|
#     (1..5).each do |i|
#         UserCategory.create({
#             category_id: i,
#             user_id: j,
#         })
#     end
# end