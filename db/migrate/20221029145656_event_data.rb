class EventData < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :description, :string
    add_column :events, :start, :date
    add_column :events, :end, :date
    add_column :events, :meetCode, :string

    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
