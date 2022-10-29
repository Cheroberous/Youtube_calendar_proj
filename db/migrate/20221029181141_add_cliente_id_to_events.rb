class AddClienteIdToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :clienteID, :string
  end
end
