class User < ActiveRecord::Base
  extend Generator

  def generate_salted_password(raw_password)
    password_signer = Digest::HMAC.new(salt, Digest::SHA1)
    password_signer.hexdigest(raw_password)
  end

end
