class AddIndexToUsuariosEmailUnique < ActiveRecord::Migration[8.0]
  def change
    add_index :usuarios, :email, unique: true
  end
end
