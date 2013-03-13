require 'spec_helper'

describe Url do
  let (:sample_data) { {original: "http://jumpstartlab.com", shortened: Url.random_string} }
  let (:sample_url) { Url.new(sample_data) }

  describe ".new" do
    it "allows creation of a new instance" do
      expect(sample_url.original).to eq("http://jumpstartlab.com")
    end
  end

  describe "#shorten" do
    it "returns a random 8 character string" do
      string1 = Url.random_string
      string2 = Url.random_string
      expect(string1).to_not eq(string2)
    end

    it "saves to the database" do
      Url.create(sample_data)
      url = Url.where(original: "http://jumpstartlab.com").first
      puts url.shortened
      expect(url.original).to eq("http://jumpstartlab.com")
    end
  end

end
