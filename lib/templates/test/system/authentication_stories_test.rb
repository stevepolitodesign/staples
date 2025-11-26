require "application_system_test_case"

class AuthenticationStoriesTest < ApplicationSystemTestCase
  test "registering an account" do
    attributes_for(:user) => {email:, password:}

    visit root_path

    within "nav" do
      click_link "Register"
    end

    fill_in "Email", with: email
    fill_in "Password", with: password
    fill_in "Password confirmation", with: "password mismatch"
    click_button "Sign up"

    assert_text "Password confirmation doesn't match Password"

    fill_in "Email", with: email
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password
    click_button "Sign up"

    assert_text I18n.translate("devise.registrations.signed_up_but_unconfirmed")

    open_email email
    current_email.click_link "Confirm my account"

    assert_text I18n.translate("devise.confirmations.confirmed")
  end

  test "logging in" do
    attributes_for(:user) => {email:, password:}
    create(:user, :confirmed, email:, password:)

    visit root_path

    within "nav" do
      click_link "Log in"
    end

    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Log in"

    assert_text I18n.translate("devise.sessions.signed_in")

    within "nav" do
      assert_no_link "Log in"
      assert_link email, href: edit_user_registration_path
    end
  end

  test "logging out" do
    user = create(:user, :confirmed)

    sign_in_as user

    visit root_path

    within "nav" do
      click_button "Log out"
    end

    assert_text I18n.translate("devise.sessions.signed_out")

    within "nav" do
      assert_no_button "Log out"
    end
  end
end
