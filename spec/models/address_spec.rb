# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'validations' do
    subject { build(:address) }

    describe 'cep' do
      it 'is required' do
        subject.cep = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:cep]).to include("can't be blank")
      end

      it 'must be unique' do
        create(:address, cep: '01310-100')
        subject.cep = '01310-100'

        expect(subject).not_to be_valid
        expect(subject.errors[:cep]).to include('has already been taken')
      end

      it 'accepts valid CEP with dash' do
        subject.cep = '01310-100'
        expect(subject).to be_valid
      end

      it 'accepts valid CEP without dash' do
        subject.cep = '01310100'
        expect(subject).to be_valid
      end
    end

    describe 'required fields' do
      it 'requires state' do
        subject.state = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:state]).to include("can't be blank")
      end

      it 'requires city' do
        subject.city = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:city]).to include("can't be blank")
      end

      it 'requires neighborhood' do
        subject.neighborhood = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:neighborhood]).to include("can't be blank")
      end

      it 'requires street' do
        subject.street = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:street]).to include("can't be blank")
      end
    end

    describe 'optional fields' do
      it 'allows nil longitude' do
        subject.longitude = nil
        expect(subject).to be_valid
      end

      it 'allows nil latitude' do
        subject.latitude = nil
        expect(subject).to be_valid
      end

      it 'accepts valid coordinates' do
        subject.longitude = -46.633309
        subject.latitude = -23.550520
        expect(subject).to be_valid
      end
    end
  end

  describe 'factory' do
    it 'creates a valid address' do
      address = build(:address)
      expect(address).to be_valid
    end

    it 'persists to database' do
      expect { create(:address) }.to change(Address, :count).by(1)
    end
  end

  describe 'database constraints' do
    it 'enforces uniqueness at database level' do
      create(:address, cep: '01310-100')

      expect do
        Address.create!(
          cep: '01310-100',
          state: 'SP',
          city: 'São Paulo',
          neighborhood: 'Bela Vista',
          street: 'Avenida Paulista'
        )
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'attributes' do
    let(:address) { create(:address) }

    it 'has a CEP' do
      expect(address.cep).to be_present
    end

    it 'has a state' do
      expect(address.state).to be_present
    end

    it 'has a city' do
      expect(address.city).to be_present
    end

    it 'has a neighborhood' do
      expect(address.neighborhood).to be_present
    end

    it 'has a street' do
      expect(address.street).to be_present
    end

    it 'may have coordinates' do
      address.update(longitude: -46.633309, latitude: -23.550520)
      expect(address.longitude).to eq(-46.633309)
      expect(address.latitude).to eq(-23.550520)
    end

    it 'has timestamps' do
      expect(address.created_at).to be_present
      expect(address.updated_at).to be_present
    end
  end
end
