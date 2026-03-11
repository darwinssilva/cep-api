# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe AddressService, type: :service do
  let(:cep) { '12345678' }
  let(:service) { described_class.new(cep) }

  describe '#call' do
    context 'when API returns success' do
      let(:response_body) do
        {
          cep: '12345678',
          state: 'SP',
          city: 'São Paulo',
          neighborhood: 'Centro',
          street: 'Praça da Sé',
          location: {
            coordinates: {
              longitude: '-46.6333',
              latitude: '-23.5505'
            }
          }
        }.to_json
      end

      before do
        stub_request(:get, "https://brasilapi.com.br/api/cep/v2/#{cep}")
          .to_return(status: 200, body: response_body, headers: {})
      end

      it 'returns a new Address instance' do
        result = service.call

        expect(result).to be_a(Address)
        expect(result.cep).to eq('12345678')
        expect(result.city).to eq('São Paulo')
        expect(result.state).to eq('SP')
        expect(result.latitude.to_f).to eq(-23.5505)
        expect(result.longitude.to_f).to eq(-46.6333)
      end
    end

    context 'when API returns 404' do
      before do
        stub_request(:get, "https://brasilapi.com.br/api/cep/v2/#{cep}")
          .to_return(status: 404, body: '')
      end

      it 'raises CEP not found error' do
        expect { service.call }
          .to raise_error(RuntimeError, "CEP not found: #{cep}")
      end
    end

    context 'when API returns 400' do
      before do
        stub_request(:get, "https://brasilapi.com.br/api/cep/v2/#{cep}")
          .to_return(status: 400, body: '')
      end

      it 'raises invalid CEP error' do
        expect { service.call }.to raise_error(RuntimeError, "Invalid CEP format: #{cep}")
      end
    end

    context 'when API returns unexpected error' do
      before do
        stub_request(:get, "https://brasilapi.com.br/api/cep/v2/#{cep}")
          .to_return(status: 500, body: '')
      end

      it 'raises external API error' do
        expect { service.call }.to raise_error(RuntimeError, /Error fetching address data for CEP #{cep}: 500/)
      end
    end
  end
end
