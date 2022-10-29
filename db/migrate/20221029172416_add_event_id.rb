class AddEventId < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :eventID, :string
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
