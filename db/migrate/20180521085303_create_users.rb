class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :phone
      t.string :address
      t.string :city
      t.string :phone
      t.string :country
      t.column :role, :integer, default: 0

      t.timestamps
    end
  end
end
