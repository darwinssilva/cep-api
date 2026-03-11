class AddressesController < ApplicationController
  def create
    cep = address_params[:cep]

    return unless valid_cep?(cep)

    @address ||= Address.find_by(cep: cep) || AddressService.new(cep).call

    if @address.save
      render json: @address, status: :created
    else
      render json: { errors: @address.errors }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def address_params
    params.require(:address).permit(:cep)
  end

  def valid_cep?(cep)
    return true if cep.present? && cep.match?(/\A\d{5}-?\d{3}\z/)

    render json: { error: 'Invalid CEP format. Expected format: 12345-678 or 12345678.' }, status: :bad_request
    false
  end
end