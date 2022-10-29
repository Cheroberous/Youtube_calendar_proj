class AddManagerIdToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :managerID, :string
  end
end
