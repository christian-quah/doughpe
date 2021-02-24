class Product < ApplicationRecord
  belongs_to :user
  has_many :slots, dependent: :destroy
  validates :name, presence: true
  validates :price, presence: true
end
