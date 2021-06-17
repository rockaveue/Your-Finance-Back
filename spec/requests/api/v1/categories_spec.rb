require 'rails_helper'

# RSpec.describe "Api::V1::Categories", type: :request do
#   describe "GET /index" do
#     pending "add some examples (or delete) #{__FILE__}"
#   end
# end

def authenticated_header(user, password)
  response = AuthenticateUser.call(user, password)
  { "Authorization" => response.result}
end

def auth_spec_request(user)
  request.headers.merge!(user.create_new_auth_token) if sign_in(user)
end

# describe 'Categories API', type: :request do
#   it 'returns default categories' do
#     # request.headers.merge!(authenticated_header("ra.by.duk@gmail.com", "123456789a"))
#     user = User.find(1)
#     auth_spec_request(user)
#     get '/api/v1/defaultCategory'
#     puts response.body
#     expect(response).to have_http_status(:success)
#   end
# end
