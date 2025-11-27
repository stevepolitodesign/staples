class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :organization, null: false, foreign_key: true
      t.index [:user_id, :organization_id], unique: true

      t.timestamps
    end
  end
end
