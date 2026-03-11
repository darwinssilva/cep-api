# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.string :cep
      t.string :state
      t.string :city
      t.string :neighborhood
      t.string :street
      t.decimal :longitude
      t.decimal :latitude

      t.timestamps
    end
  end
end
