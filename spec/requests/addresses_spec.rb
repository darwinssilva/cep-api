# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Addresses API', type: :request do
  let(:cep) { '12345678' }

  describe 'POST /addresses' do
    context 'when CEP is valid' do
      let(:address) do
        Address.new(
          cep: cep,
          city: 'São Paulo',
          state: 'SP',
          neighborhood: 'Centro',
          street: 'Praça da Sé',
          latitude: -23.5505,
          longitude: -46.6333
        )
      end

      before do
        allow(FindAddressService)
          .to receive(:new)
          .with(cep)
          .and_return(instance_double(FindAddressService, call: address))
      end

      it 'returns the address' do
        post '/addresses', params: { address: { cep: cep } }

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)

        expect(json['cep']).to eq(cep)
        expect(json['city']).to eq('São Paulo')
        expect(json['state']).to eq('SP')
      end
    end

    context 'when CEP format is invalid' do
      it 'returns bad request error' do
        post '/addresses', params: { address: { cep: '123' } }

        expect(response).to have_http_status(:bad_request)

        json = JSON.parse(response.body)

        expect(json['error']).to eq('Invalid CEP format. Expected format: 12345-678 or 12345678.')
      end
    end

    context 'when service raises error' do
      before do
        allow(FindAddressService)
          .to receive(:new)
          .and_raise(StandardError.new('Unexpected error'))
      end

      it 'returns internal server error' do
        post '/addresses', params: { address: { cep: cep } }

        expect(response).to have_http_status(:internal_server_error)

        json = JSON.parse(response.body)

        expect(json['error']).to eq('Unexpected error')
      end
    end
  end
end
