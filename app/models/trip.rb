class Trip < ApplicationRecord
  include PgSearch::Model
  include Filterable

  before_validation :strip_attributes

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }
  validates :image_url, presence: true, length: { maximum: 65_535 }
  validates :short_description, presence: true, length: { maximum: 65_535 }
  validates :long_description, length: { maximum: 65_535 }, allow_nil: true
  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5, message: :rating_range }

  pg_search_scope :combined_search,
    against: {
      name: "A"
    },
    using: {
      tsearch: { prefix: true },
      trigram: { threshold: 0.4 }
    },
    ranked_by: ":tsearch + (0.5 * :trigram)"

    scope :filter_by_search, ->(term) { combined_search(term) }
    scope :filter_by_min_rating, ->(min) { where("rating >= ?", min.to_i) }

    scope :order_by_name,   ->(dir = :asc) { reorder(name: dir.to_sym) }
    scope :order_by_rating, ->(dir = :asc) { reorder(rating: dir.to_sym) }

    private

    def strip_attributes
      attributes.each do |attr, value|
        self[attr] = value.strip if value.is_a?(String)
      end
    end
end
