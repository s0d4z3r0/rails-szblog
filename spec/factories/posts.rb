FactoryBot.define do
  factory :post do
    titulo { "Título de exemplo" }
    texto { "Conteúdo do post de exemplo" }
    association :usuario
  end
end
