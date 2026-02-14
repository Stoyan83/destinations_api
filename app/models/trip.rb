class Trip < ApplicationRecord
  include PgSearch::Model

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }
  validates :image_url, presence: true, length: { maximum: 65_535 }
  validates :short_description, presence: true, length: { maximum: 65_535 }
  validates :long_description, length: { maximum: 65_535 }, allow_nil: true
  validates :rating, presence: true, inclusion: { in: 1..5, message: :rating_range }

  pg_search_scope :combined_search,
    against: {
      name: 'A'  
    },
    using: {
      tsearch: { prefix: true },  
      trigram: { threshold: 0.4 }
    },
    ranked_by: ":tsearch + (0.5 * :trigram)"
end