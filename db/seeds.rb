# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# employee_list = [
#     [ 'bold', 'bold@email', 'erdene', '123', 0],
#     [ 'bat', 'bat@email', 'saihan', '123', 0],
#     [ 'dulguun', 'dulguun@email', 'tuguldur', '123', 0],
#     [ 'erdene', 'erdene@email', 'bat', '123', 0]
# ]

# employee_list.each do | name, email, last_name, password, balance|
#     User.create( first_name: name, email: email, last_name: last_name, password: password, balance: balance)
# end

10.times do
    User.create({
        email: Faker::Internet.email,
        password: '123',
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        balance: Faker::Number.number(digits: 6)
    })
end