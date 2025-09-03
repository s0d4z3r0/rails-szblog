class ComentarioSerializer < ActiveModel::Serializer
  attributes :id, :comentario, :usuario_id, :post_id
end
