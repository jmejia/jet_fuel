require 'spec_helper'

describe PrivateUrl do
  let (:db_user) { User.all.first }
  let (:sample_url) { PrivateUrl.new({original: "http://espn.com"}) }

  describe ".new" do
    it "allows creation of a new instance" do
      expect(sample_url.original).to eq("http://espn.com")
    end
  end

  describe "#create" do
    it "requires a user to be logged" do
      expect(PrivateUrl.create())
    end
  end

  #describe "#shorten" do
  #  it "returns a random 8 character string" do
  #    string1 = PrivateUrl.random_string
  #    string2 = PrivateUrl.random_string
  #    expect(string1).to_not eq(string2)
  #  end

  #  it "saves to the database" do
  #    PrivateUrl.create(sample_data)
  #    url = PrivateUrl.where(original: "http://jumpstartlab.com").first
  #    expect(url.original).to eq("http://jumpstartlab.com")
  #  end
  #end

end
