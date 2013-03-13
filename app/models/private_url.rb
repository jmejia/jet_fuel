class PrivateUrl < ActiveRecord::Base
  extend Generator
  validate :original, :shortened, presence: true
end
