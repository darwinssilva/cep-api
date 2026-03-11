# frozen_string_literal: true

class FindAddressService
  def initialize(cep)
    @cep = cep
  end

  def call
    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      find_or_fetch_address
    end
  end

  private

  def find_or_fetch_address
    Address.find_by(cep: @cep) || fetch_address_data
  end

  def cache_key
    "address:#{@cep}"
  end

  def fetch_address_data
    address = AddressService.new(@cep).call
    address.save!
    address
  end
end
