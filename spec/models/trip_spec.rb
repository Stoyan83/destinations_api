require 'rails_helper'

RSpec.describe Trip, type: :model do
  subject { build(:trip) }

  describe 'validations' do
      it { should validate_presence_of(:name) }
      it { should validate_uniqueness_of(:name).case_insensitive }
      it { should validate_length_of(:name).is_at_most(255) }

      it { should validate_presence_of(:image_url) }
      it { should validate_length_of(:image_url).is_at_most(65_535) }

      it { should validate_presence_of(:short_description) }
      it { should validate_length_of(:short_description).is_at_most(65_535) }

      it { should allow_value(nil).for(:long_description) }
      it { should validate_length_of(:long_description).is_at_most(65_535) }

      it { should validate_presence_of(:rating) }
      it { should validate_inclusion_of(:rating).in_range(1..5).with_message(:rating_range) } 
  end
end
  