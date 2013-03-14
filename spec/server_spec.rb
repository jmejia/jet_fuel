require 'spec_helper'

describe Server do
  include Rack::Test::Methods

  def app
    Server
  end

  describe "/" do
    it "loads index page" do
      get "/"
      expect(last_response.status).to eq(200)
    end
  end

  describe "/shorten" do
    describe "at /shorten" do
      context "given valid and unique parameters" do
        it "shortens the original url" do
          post "/shorten", {"url" => "http://espn.com"}
          expect(URI(last_response["Location"]).path.split("").count).to eq(12)
        end

        it "redirects if the url does not exist" do
          post "/shorten", {"url" => "http://espn.com"}
          expect(last_response.status).to eq(302)
        end

        it "redirects if the url does exist" do
          Url.create({original: "http://espn.com", shortened: "abcdefgh"})
          post "/shorten", {"url" => "http://espn.com"}
          expect(last_response["Location"]).to include("abcdefgh")
        end

        it "creates a private url if logged in and doesn't exist" do
          post "/login", {username: "jmejia", password: "asdf"}
          post "/shorten", {"url" => "http://easdadsfasdfasdfa.com"}
          expect(last_response.status).to be(302)
        end

        it "finds existing url if logged in and exists" do
          PrivateUrl.create({original: "http://espn.com", shortened: "defghi"})
          post "/login", {username: "jmejia", password: "asdf"}
          post "/shorten", {"url" => "http://espn.com"}
          expect(last_response["Location"]).to include("defghi")
        end
      end
    end
  end

  describe "/urls" do
    it "displays a list of public urls" do
      get "/urls"
      expect(last_response).to be_ok
    end
  end

  describe "/urls/:shortened" do
    it "displays has a page for a public url" do
      url = Url.create( {original: "http://hulu.com", shortened: "asdfasdf", count: 0} )
      get "/urls/#{url.shortened}"
      expect(last_response.status).to eq(200)
    end
  end

  describe "/*" do
    it "redirects a shortened URL to the original URL" do
      Url.create({original: "http://hulu.com", shortened: "asdfasdf", count: 0})
      url = Url.find_by_shortened("asdfasdf")
      get "/#{url.shortened}"
      expect(last_response.status).to eq(302)
    end

    it "redirects a an invalid URL to the URL index page" do
      get "/some_made_up_url"
      expect(last_response["Location"]).to eq("http://example.org/urls")
    end
  end

  describe "/users/new" do
    it "successfully loads a page" do
      get "/users/new"
      expect(last_response.status).to eq(200)
    end
  end

  describe "/users/create" do
    it "displays a message if the user already exists" do
      post "/users/create", {username: "josh"}
      expect(last_response.body).to include("User Already Exists")
    end

    it "fails if passwords do not match" do
      post "/users/create", {username: "joshuamejia", password: "asdf", confirmation: "wrong"}
      expect(last_response.body).to include("did not match")
    end

    it "creates a new user if unique and passwords match" do
      post "/users/create", {username: "joshuamejia", password: "asdf", confirmation: "asdf"}
      expect(last_response.status).to eq(302)
    end
  end

  describe "/users/:username" do
    it "returns a message if user is invalid" do
      get "/users/jasdfadf"
      expect(last_response.body).to eq("Invalid User")
    end

    it "dispays user info if user exists" do
      get "/users/josh"
      expect(last_response.body).to include("josh")
    end
  end

  describe "/login" do
    it "displays a message if user does not exist" do
      post "/login", {username: "asdfasdf"}
      expect(last_response.body).to include("Invalid User")
    end

    it "display a message if the user exists" do
      post "/login", {username: "josh"}
      expect(last_response.body).to include("success")
    end

    it "returns a message if passwords don't match" do
      get "/logout"
      post "/login", {username: "josh", password: "asdf"}
      expect(last_response.body).to include("Invalid Password")
    end

    it "confirms salted passwords should match" do
      post "/login", {username: "jmejia", password: "asdf"}
      expect(last_response.status).to eq(302)
    end
  end

  describe "/users/:username/urls/:shortened/" do
    it "redirects to home page if not logged in" do
      get "/logout"
      get "/users/jmejia/urls/eihbji"
      expect(last_response["Location"][-1]).to eq("/")
    end

    it "displays the url show page if user and private url are valid" do
      post "/login", {username: "jmejia", password: "asdf"}
      get "/users/jmejia/urls/eihbji"
      expect(last_response.body).to include("Shortened URL")
    end

    it "redirects to current user page if logged in and private url is not valid" do
      post "/login", {username: "jmejia", password: "asdf"}
      get "/users/jmejia/urls/eihbjasdfadsf"
      expect(last_response["Location"]).to include("users/jmejia")
    end
  end
end
