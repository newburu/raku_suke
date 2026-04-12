class ChangeResponsesColumnInAttendances < ActiveRecord::Migration[7.2]
  def change
    # MariaDB の json 型は json_valid() チェック制約が付き、Ruby記法のHashが弾かれるため
    # text 型に変更し、Rails側でシリアライズを管理する
    change_column :attendances, :responses, :text
  end
end
