class CreateDislikes < ActiveRecord::Migration[6.0]
  def change
    create_table :dislikes do |t|
      t.string :user
      t.string :cafe

      t.timestamps
    end
  end
end
