class AddUsuarioToComentarios < ActiveRecord::Migration[8.0]
  def change
    add_reference :comentarios, :usuario, null: false, foreign_key: true
  end
end
