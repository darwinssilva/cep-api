# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindAddressService, type: :service do
  let(:cep) { '12345678' }
  let(:service) { described_class.new(cep) }

  before do
    Rails.cache.clear
  end

  describe '#call' do
    context 'when address already exists in database' do
      let!(:address) { create(:address, cep: cep) }

      it 'returns the existing address without calling external service' do
        expect(AddressService).not_to receive(:new)

        result = service.call

        expect(result).to eq(address)
      end
    end

    context 'when address does not exist in database' do
      let(:new_address) { build(:address, cep: cep) }

      before do
        allow(AddressService).to receive(:new).with(cep).and_return(
          instance_double(AddressService, call: new_address)
        )
      end

      it 'calls external service and saves the address' do
        expect { service.call }.to change(Address, :count).by(1)

        result = service.call

        expect(result.cep).to eq(cep)
      end
    end

    context 'when address is cached' do
      let!(:address) { create(:address, cep: cep) }

      it 'returns address from cache' do
        first_call = service.call

        expect(AddressService).not_to receive(:new)

        second_call = service.call

        expect(second_call).to eq(first_call)
      end
    end

    context 'when external service raises error' do
      before do
        allow(AddressService).to receive(:new).and_raise(StandardError.new('API error'))
      end

      it 'raises the error' do
        expect { service.call }.to raise_error(StandardError, 'API error')
      end
    end
  end
end
