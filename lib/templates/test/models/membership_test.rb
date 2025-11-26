require "test_helper"

class Membership::DatabaseConstraintTest < ActiveSupport::TestCase
  test "uniqueness constraint" do
    membership = create(:membership)
    user = membership.user
    organization = membership.organization

    assert_raises ActiveRecord::RecordNotUnique do
      create(:membership, user:, organization:)
    end
  end
end
