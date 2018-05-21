class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  validates :name, presence: true, length: {maximum: Settings.category.length}
end
