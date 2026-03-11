class Address < ApplicationRecord
  validates :cep, presence: true, uniqueness: true
  validates :state, :city, :neighborhood, :street, presence: true
end
