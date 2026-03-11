# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    sequence(:cep) { |n| format('%08d', n) }
    state { 'SP' }
    city { 'São Paulo' }
    neighborhood { 'Centro' }
    street { 'Rua das Flores, 123' }
    longitude { -46.633309 }
    latitude { -23.550520 }
  end
end
