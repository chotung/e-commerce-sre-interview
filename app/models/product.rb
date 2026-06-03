class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :category, type: String
  field :description, type: String
  field :price_cents, type: Integer
  field :inventory_count, type: Integer
  field :active, type: Boolean, default: true

  # Validations
  validates :name, presence: true
  validates :category, presence: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :inventory_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Indexes
  index({ name: 1 })
  index({ category: 1 })
  index({ active: 1 })
end
