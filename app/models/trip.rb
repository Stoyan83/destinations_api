class Trip < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :rating, presence: true, inclusion: { in: 1..5, message: :rating_range }
end