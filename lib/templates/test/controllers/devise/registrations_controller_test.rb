require "test_helper"

module Devise
  class RegistrationsController::CreateTest < ActionDispatch::IntegrationTest
    test "creates initial organization on successful registration" do
      attributes_for(:user) => {email:, password:}

      assert_changes -> { User.count }, from: 0, to: 1 do
        assert_changes -> { Organization.count }, from: 0, to: 1 do
          post user_registration_path, params: {
            user: {
              email:,
              password:,
              password_confirmation: password
            }
          }
        end
      end

      user = User.sole
      organization = Organization.sole

      assert_equal organization, user.organization
    end

    test "does not create initial organization on unsuccessful registration" do
      assert_no_changes -> { User.count }, from: 0 do
        assert_no_changes -> { Organization.count }, from: 0 do
          post user_registration_path, params: {
            user: {
              email: "",
              password: "",
              password_confirmation: ""
            }
          }
        end
      end
    end
  end
end
