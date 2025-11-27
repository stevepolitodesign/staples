require "test_helper"

class User::CreateInitialOrganizationTest < ActiveSupport::TestCase
  test "creates organization on create" do
    user = build(:user)

    assert_changes -> { Organization.count }, from: 0, to: 1 do
      user.save!
    end

    user = User.sole
    organization = Organization.sole

    assert_equal organization, user.organization
  end

  test "does not create organization on update" do
    user = create(:user)

    assert_no_changes -> { Organization.count }, from: 1 do
      user.update! email: "updated@example.com"
    end
  end
end

class User::DestroyTest < ActiveSupport::TestCase
  test "destroys associated membership" do
    user = create(:user)

    assert_no_changes -> { Organization.count }, from: 1 do
      assert_changes -> { Membership.count }, from: 1, to: 0 do
        user.destroy!
      end
    end
  end
end
