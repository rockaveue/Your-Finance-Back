require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  it "returns user" do
    get "/api/v1/users/1"

    expect(response).to have_http_status(:success)
  end
end
