require 'spec_helper'

describe User do
  let (:sample_user) { {username: "jmejia", salt: User.random_string} }
  describe ".new" do
    it "can create a new instance" do
      user = User.new(sample_user)
      expect(user.username).to eq("jmejia")
    end

    it "generates a unique salt" do
      user = User.new(sample_user)
      user2 = User.new({username:"rmejia", salt: User.random_string})
      expect(user.salt).to_not eq(user2.salt)
    end

    it "generates a consistant salted password" do
      user = User.new({username: "jmejia", salt: "eyezcwag"})
      salted_password = user.generate_salted_password("josh")
      db_user = User.create(username: user.username, salt: "eyezcwag", salted_password: salted_password)
      expect(db_user.salted_password).to eq("347788d8d500ecc6600f16613789aaebcf26a4e2")
    end

    it "saves a user with attributes" do
      User.create(sample_user)
      user = User.where(:username => "jmejia").first
      expect(user.username).to eq("jmejia")
    end

  end
end
