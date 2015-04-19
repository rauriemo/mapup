class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :profile_pic
      t.string :password
      t.string :email
      t.integer :pic_count
      t.timestamps
    end
  end
end
