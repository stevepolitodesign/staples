module User::Account
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :registerable,
      :recoverable, :rememberable, :validatable,
      :confirmable, :trackable

    after_create_commit :create_initial_organization!

    has_many :memberships, dependent: :destroy
    has_many :organizations, through: :memberships
  end

  def organization
    organizations.sole
  end

  private

  def create_initial_organization!
    organizations.create!
  end
end
