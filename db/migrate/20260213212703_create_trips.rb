class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      t.string  :name, null: false
      t.text    :image_url, null: false
      t.text    :short_description, null: false
      t.text    :long_description
      t.integer :rating, null: false, default: 1

      t.timestamps
    end

    add_check_constraint :trips, 'rating >= 1 AND rating <= 5', name: 'rating_range'

    add_index :trips, :rating
    add_index :trips, :name, unique: true
    add_index :trips, :name, using: :gin, opclass: :gin_trgm_ops, name: "index_trips_on_name_trgm"
  end
end
