class CreateUserPrivateUrls < ActiveRecord::Migration
  def change
    create_table :user_private_urls do |t|
      t.references :user
      t.references :private_url
    end
  end
end
