class Comentario < ApplicationRecord
  belongs_to :usuario
  belongs_to :post
  validates :post_id, presence: true
  validates :comentario, presence: true
end
