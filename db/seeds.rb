# User seeder
10.times do
    User.create({
        email: Faker::Internet.email,
        password: Devise::Encryptor.digest(User, '123'),
        encrypted_password: Devise::Encryptor.digest(User, '123'),
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        balance: Faker::Number.number(digits: 6)
    })
end

# ---------------------------------------------
# Category seeder
# 10.times do
#     Category.create({
#             category_name: Faker::JapaneseMedia::OnePiece.location,
#             category_type: Faker::Number.between(from: 0, to: 1),
#             is_default: Faker::Number.between(from: 0, to: 1)
#         })
#     end
    
# # ---------------------------------------------
# # # Transaction seeder
# 10.times do
#     Transaction.create({
#         category_id: Faker::Number.between(from:1, to: 10),
#         user_id: Faker::Number.between(from:1, to: 10),
#         transaction_type: Faker::Boolean.boolean,
#         transaction_date: Faker::Date.between(from: 1.year.ago, to: Date.today),
#         amount: Faker::Number.between(from: 0, to: 1000000, ),
#         is_repeat: Faker::Boolean.boolean,
#         note: Faker::Lorem.sentence(word_count: 3)
#     })
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


# Ajillahgui seeder
# 10.times do
#     @user = User.create!({
#         email: Faker::Internet.email,
#         password: Devise::Encryptor.digest(User, '123'),
#         encrypted_password: Devise::Encryptor.digest(User, '123'),
#         first_name: Faker::Name.first_name,
#         last_name: Faker::Name.last_name,
#         balance: Faker::Number.number(digits: 6)
#     })
#     rand(1..3).times do
#         trans = Transaction.create!({
    
#             category_id: Faker::Number.between(from:1, to: 10),
#             user_id: @user,
#             transaction_type: Faker::Boolean.boolean,
#             transaction_date: Faker::Date.between(from: 1.year.ago, to: Date.today),
#             amount: Faker::Number.between(from: 0, to: 1000000, ),
#             is_repeat: Faker::Boolean.boolean,
#             note: Faker::Lorem.sentence(word_count: 3)
#         })
#     end
# end