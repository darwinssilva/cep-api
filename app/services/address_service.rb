# frozen_string_literal: true

require 'net/http'
require 'json'

class AddressService
  BASE_URL = 'https://brasilapi.com.br/api/cep/v2/'

  def initialize(cep)
    @cep = cep
  end

  def call
    data = fetch_address_data
    return unless data

    build_address(data)
  end

  private

  def build_address(data)
    Address.new(
      cep: data['cep'],
      state: data['state'],
      city: data['city'],
      neighborhood: data['neighborhood'],
      street: data['street'],
      longitude: data.dig('location', 'coordinates', 'longitude'),
      latitude: data.dig('location', 'coordinates', 'latitude')
    )
  end

  def fetch_address_data
    url = URI("#{BASE_URL}#{@cep}")
    response = Net::HTTP.get_response(url)

    handle_response(response)
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      JSON.parse(response.body)
    when Net::HTTPNotFound
      raise "CEP not found: #{@cep}"
    when Net::HTTPBadRequest
      raise "Invalid CEP format: #{@cep}"
    else
      raise "Error fetching address data for CEP #{@cep}: #{response.code}"
    end
  end
end
