class PrivateUrl < ActiveRecord::Base
  extend Generator
  has_many :user_private_urls, dependent: :destroy
  validate :original, :shortened, presence: true
end
