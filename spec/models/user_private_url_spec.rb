require 'spec_helper'

describe UserPrivateUrl do
  describe "create" do
    it "creates" do
      @current_user = User.first
      UserPrivateUrl.create({ user_id: @current_user.id, private_url_id: 3})
      search = UserPrivateUrl.find_by_user_id(1)
      expect(search.private_url_id).to eq(3)
    end
  end
end
