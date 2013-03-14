class User < ActiveRecord::Base
  extend Generator

  has_many :user_private_urls, dependent: :destroy
  has_many :private_urls, through: :user_private_urls

  def generate_salted_password(raw_password)
    password_signer = Digest::HMAC.new(salt, Digest::SHA1)
    password_signer.hexdigest(raw_password)
  end

end
