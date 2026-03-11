# frozen_string_literal: true

# Address model representing a location retrieved from a CEP lookup.
# Stores geographic coordinates and basic address information.

class Address < ApplicationRecord
  validates :cep, presence: true, uniqueness: true
  validates :state, :city, :neighborhood, :street, presence: true
end
