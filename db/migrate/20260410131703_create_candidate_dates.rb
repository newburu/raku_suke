class CreateCandidateDates < ActiveRecord::Migration[7.2]
  def change
    create_table :candidate_dates do |t|
      t.references :event, null: false, foreign_key: true
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end
