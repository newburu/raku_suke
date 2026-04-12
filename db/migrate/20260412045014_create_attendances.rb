class CreateAttendances < ActiveRecord::Migration[7.2]
  def change
    create_table :attendances do |t|
      t.references :event, null: false, foreign_key: true
      t.string :user_name
      t.json :responses

      t.timestamps
    end
  end
end
