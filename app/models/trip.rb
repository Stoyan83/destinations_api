class Trip < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }
  validates :image_url, presence: true, length: { maximum: 65_535 }
  validates :short_description, presence: true, length: { maximum: 65_535 }
  validates :long_description, length: { maximum: 65_535 }, allow_nil: true
  validates :rating, presence: true, inclusion: { in: 1..5, message: :rating_range }
end