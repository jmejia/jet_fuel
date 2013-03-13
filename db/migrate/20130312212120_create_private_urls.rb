class CreatePrivateUrls < ActiveRecord::Migration
  def change
    create_table :private_urls do |t|
      t.string :original
      t.string :shortened
    end
  end
end
