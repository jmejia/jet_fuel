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
          expect(URI(last_response["Location"]).path.split("").count).to eq(14)
        end

        it "redirects if the url does not exist" do
          post "/shorten", {"url" => "http://espn.com"}
          expect(last_response.status).to eq(302)
        end

        it "redirects if the url does not exist" do
          Url.create({original: "http://espn.com", shortened: "abcdefgh"})
          post "/shorten", {"url" => "http://espn.com"}
          expect(last_response["Location"]).to include("abcdefgh")
        end
      end
    end
  end

  describe "/urls" do
    it "displays a list of public urls" do
      get "/urls"
      expect(last_response.body).to include("jumpstartlab.com")
      expect(last_response).to be_ok
    end
  end

  describe "/urls/:shortened" do
    let (:url) {Url.first}
    it "displays has a page for a public url" do
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

  describe "/login" do
    it "loads a page without an error" do
      get "/login"
      expect(last_response.status).to eq(200)
    end

    it "has a form" do
      get "/login"
      expect(last_response.body).to include("<form")
    end
  end
end
