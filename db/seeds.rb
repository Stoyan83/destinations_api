file_path = Rails.root.join('db', 'seeds', 'data.json')


trips_data = JSON.parse(File.read(file_path))['trips']


bulk_trips = trips_data.map do |trip|
  {
      name: trip['name'],
      image_url: trip['image'],
      short_description: trip['short_description'] || trip['description'],
      long_description: trip['long_description'],
      rating: trip['rating'],
      created_at: Time.current,
      updated_at: Time.current
  }
end
  
Trip.upsert_all(bulk_trips, unique_by: :name)

puts "✅ Successfully seeded #{bulk_trips.size} trips into the database."
