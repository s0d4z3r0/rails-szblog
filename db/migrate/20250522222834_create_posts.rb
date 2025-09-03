class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :titulo
      t.text :texto
      t.references :usuario, null: false, foreign_key: true

      t.timestamps
    end
  end
end
