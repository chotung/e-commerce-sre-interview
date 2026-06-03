class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :status, type: String
  field :items, type: Array, default: []
  field :subtotal_cents, type: Integer
  field :tax_cents, type: Integer
  field :total_cents, type: Integer

  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true
  validates :items, presence: true
  validates :subtotal_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Indexes
  index({ email: 1 })
  index({ status: 1 })
  index({ created_at: -1 })
end
