require "test_helper"

class Organization::DestroyTest < ActiveSupport::TestCase
  test "raises" do
    user = create(:user)

    assert_raise ActiveRecord::DeleteRestrictionError do
      user.organization.destroy
    end
  end

  test "destroys" do
    organization = create(:organization)

    assert_changes -> { Organization.count }, from: 1, to: 0 do
      organization.destroy
    end
  end
end
