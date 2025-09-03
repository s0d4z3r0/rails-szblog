FactoryBot.define do
  factory :usuario do
    nome { "Usuário de Teste" }
    email { Faker::Internet.unique.email }
    password { "senha123" }
    password_confirmation { "senha123" }
  end
end
