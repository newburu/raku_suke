class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :token

      t.timestamps
    end
    add_index :events, :token, unique: true
  end
end
