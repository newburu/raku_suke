class AddCommentToAttendances < ActiveRecord::Migration[7.2]
  def change
    add_column :attendances, :comment, :text
  end
end
