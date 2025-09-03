class Post < ApplicationRecord
  belongs_to :usuario
  has_many :comentarios, dependent: :destroy

  validates :titulo, presence: true
  validates :texto, presence: true
end
