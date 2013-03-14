class UserPrivateUrl < ActiveRecord::Base
  belongs_to :user
  belongs_to :private_url
end
