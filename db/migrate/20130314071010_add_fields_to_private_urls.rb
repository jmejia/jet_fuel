class AddFieldsToPrivateUrls < ActiveRecord::Migration
  def change
    add_column(:private_urls, :count, :integer)
    add_column(:private_urls, :created_at, :datetime)
    add_column(:private_urls, :updated_at, :datetime)
  end
end
