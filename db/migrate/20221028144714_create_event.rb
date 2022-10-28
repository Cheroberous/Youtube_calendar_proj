class CreateEvent < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :summary
    end
  end
end
