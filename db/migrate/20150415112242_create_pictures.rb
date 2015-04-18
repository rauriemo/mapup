class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.references :user
      t.date :date
      t.binary :image
      t.string :latitude
      t.string :longitude
      t.timestamps
    end
  end
end
