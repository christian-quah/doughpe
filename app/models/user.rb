class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :products, dependent: :destroy
  has_many :slots, through: :products
  has_many :orders, through: :slots
  has_many :reviews, through: :orders
  has_many :baskets
  validates :username, presence: true, uniqueness: true
  has_one_attached :photo
end
