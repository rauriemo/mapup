class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :user
      t.binary :profile_pic
      t.string :description
      t.timestamps
    end
  end
end
