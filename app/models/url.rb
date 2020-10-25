
class Url < ApplicationRecord
  # scope :latest, -> {}
  validates :original_url, url: true
  has_many :clicks
  
end
