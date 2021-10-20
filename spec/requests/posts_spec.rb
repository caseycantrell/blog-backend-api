require 'rails_helper'

RSpec.describe "Posts", type: :request do

  describe "GET /posts" do

    it "should return an array of blog posts" do

      user = User.create(name: "Test", email: "test@test.com", password: "password")
      Post.create!([
        {user_id: user.id, title: "test test", body: "testtesttesttesttest"},
        {user_id: user.id, title: "this is a test", body: "check check one two one two"},
        {user_id: user.id, title: "nothing", body: "blah blah blah blah blah bliggedy blah"},
        {user_id: user.id, title: "fourth post yo", body: "yeeeeessssssssiiiiirrrrrrr"},
        ])

      get "/posts"
      posts = JSON.parse(response.body)

      expect(response).to have_http_status(200)
      expect(posts.length).to eq(4)
    end
  end

  describe "GET /posts/:id" do

    it "should return an object with the appropriate attributes" do

      user = User.create(name: "Test", email: "test@test.com", password: "password")
      Post.create({user_id: user.id, title: "test test", body: "testtesttesttesttest"})

      get "/posts/#{Post.first.id}"
      post = JSON.parse(response.body)

      expect(response).to have_http_status(200)
      expect(post["title"]).to eq("test test")
      expect(post["body"]).to eq("testtesttesttesttest")

    end
  end

  describe "POST /posts" do

    it "should create a new post when all submitted data is valid" do
    user = User.create({name: "Test", email: "test@test.com", password: "password"})
    jwt = JWT.encode({user_id: user.id}, Rails.application.credentials.fetch(:secret_key_base), "HS256")

    post "/posts", params: {title: "new post", body: "body of new post"}, headers: {"Authorization" => "Bearer #{jwt}"}
    post = JSON.parse(response.body)
    expect(response).to have_http_status(200)
    expect(post["title"]).to eq("new post")
  end

  it "should return a 401 status if user is not logged in" do
    post "/posts", params: {}
    expect(response).to have_http_status(:unauthorized)
  end

  it "should return an error code with authorization but invalid data" do
    user = User.create({name: "Test", email: "test@test.com", password: "password"})
    jwt = JWT.encode({user_id: user.id}, Rails.application.credentials.fetch(:secret_key_base), "HS256")

    post "/posts", params: {}, headers: {"Authorization" => "Bearer #{jwt}"}
    expect(response).to have_http_status(:bad_request)
    end
  end
end

