class Organization < ApplicationRecord
  has_many :memberships, dependent: :restrict_with_exception
end
