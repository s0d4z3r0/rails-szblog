class Usuario < ApplicationRecord
  has_secure_password
  has_many :posts
  has_many :comentarios
  validates :nome, presence: true
  validates :password, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :email, presence: true, uniqueness: { case_sensitive: false }
end
