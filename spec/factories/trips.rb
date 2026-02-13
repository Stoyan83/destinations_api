FactoryBot.define do
  factory :trip do
    sequence(:name) { |n| "Trip #{n}" }
    image_url { "https://example.com/image.jpg" }
    short_description { "A short description of the trip." }
    long_description { "A longer description of the trip, providing more details." }
    rating { 3 }
  end
end
