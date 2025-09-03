class CreateComentarios < ActiveRecord::Migration[8.0]
  def change
    create_table :comentarios do |t|
      t.string :nome
      t.text :comentario
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end
  end
end
