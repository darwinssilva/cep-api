require 'net/http'
require 'json'

class AddressService
  def initialize(cep)
    @cep = cep
  end

  def call
    address_data = fetch_address_data
    return nil unless address_data

    Address.new(
      cep: address_data['cep'],
      state: address_data['state'],
      city: address_data['city'],
      neighborhood: address_data['neighborhood'],
      street: address_data['street'],
      longitude: address_data['location']['coordinates']&.[]('longitude'),
      latitude: address_data['location']['coordinates']&.[]('latitude')
    )
  end

  private

  def fetch_address_data
    url = URI("https://brasilapi.com.br/api/cep/v2/#{@cep}")
    response = Net::HTTP.get_response(url)

    case response.code.to_i
    when 200
      JSON.parse(response.body)
    when 404
      raise "Address not found for CEP #{@cep}"
    when 400
      raise "Invalid CEP format: #{@cep}"
    else
      raise "Unexpected error fetching address data for CEP #{@cep}: #{response.code} #{response.message}"
    end
  rescue StandardError => e
    raise "Error fetching address data for CEP #{@cep}: #{e.message}"
  end
end