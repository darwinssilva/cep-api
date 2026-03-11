# frozen_string_literal: true

# Controller for handling address lookup by CEP (Brazilian postal code).
class AddressesController < ApplicationController
  def create
    cep = normalize_cep(address_params[:cep])

    return unless valid_cep?(cep)

    address = FindAddressService.new(cep).call

    render json: address, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def address_params
    params.require(:address).permit(:cep)
  end

  def normalize_cep(cep)
    cep.gsub(/\D/, '')
  end

  def valid_cep?(cep)
    return true if cep.present? && cep.match?(/\A\d{5}-?\d{3}\z/)

    render json: { error: 'Invalid CEP format. Expected format: 12345-678 or 12345678.' }, status: :bad_request
    false
  end
end
