require 'rails_helper'

RSpec.describe "Comentarios API", type: :request do
  let!(:usuario) { Usuario.create!(nome: "Fulano", email: "fulano@email.com", password: "senha123", password_confirmation: "senha123") }
  let!(:outro_usuario) { Usuario.create!(nome: "Ciclano", email: "ciclano@email.com", password: "senha456", password_confirmation: "senha456") }

  let!(:postagem) { Post.create!(titulo: "Post de Teste", texto: "Conteúdo do post", usuario: usuario) }
  let!(:comentario) do
    Comentario.create!(
      nome: usuario.nome,
      comentario: "Comentario de teste",
      post: postagem,
      usuario: usuario
    )
  end

  let!(:headers) { { "ACCEPT" => "application/json" } }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(usuario)
  end

  describe "GET /comentarios/:id" do
    it "retorna o comentario em JSON" do
      get comentario_path(comentario), headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(comentario.id)
      expect(json["comentario"]).to eq(comentario.comentario)
      expect(json["usuario_id"]).to eq(usuario.id)
      expect(json["post_id"]).to eq(postagem.id)
    end
  end

  describe "GET /comentarios" do
    it "retorna todos os comentarios em JSON" do
      get comentarios_path, headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first["id"]).to eq(comentario.id)
    end
  end

  describe "POST /comentarios" do
    context "com dados válidos" do
      it "cria um novo comentario" do
        expect {
          post comentarios_path,
            params: {
              comentario: {
                comentario: "Novo comentário",
                post_id: postagem.id
              }
            },
            headers: headers
        }.to change(Comentario, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["comentario"]).to eq("Novo comentário")
        expect(json["post_id"]).to eq(postagem.id)
        expect(json["usuario_id"]).to eq(usuario.id)
      end
    end

    context "com dados inválidos" do
      it "não cria o comentario e retorna os erros" do
        post comentarios_path,
          params: {
            comentario: {
              comentario: "",
              post_id: nil
            }
          },
          headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key("comentario")
        expect(json).to have_key("post")
      end
    end
  end

  describe "PATCH /comentarios/:id" do
    context "com dados válidos" do
      it "atualiza o comentario" do
        patch comentario_path(comentario),
        params: {
          comentario: { comentario: "Comentário atualizado" }
        },
        headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["comentario"]).to eq("Comentário atualizado")
      end
    end

    context "com dados inválidos" do
      it "Não atualiza o comentario e retorna os erros" do
        patch comentario_path(comentario),
        params: {
          comentario: { comentario: "" }
        },
        headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key("comentario")
      end

      it "retorna 403 ao tentar atualizar comentário de outro usuário" do
        allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(outro_usuario)
        patch comentario_path(comentario),
          params: { comentario: { comentario: "Hackeado." } },
          headers: headers

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Acesso não autorizado.")
      end
    end
  end

  describe "DELETE /comentarios/:id" do
    context "usuário deletando o próprio comentário" do
      it "exclui o comentario" do
        expect {
          delete comentario_path(comentario), headers: headers
        }.to change(Comentario, :count).by(-1)

        expect(response).to have_http_status(:see_other).or have_http_status(:no_content)
      end
    end

    context "usuário deletando comentário de outro usuário" do
      it "retorna 403 ao tentar deletar comentário de outro usuário" do
        allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(outro_usuario)
        delete comentario_path(comentario), headers: headers

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Acesso não autorizado.")
      end
    end

    context "usuário deletando comentário inexistente" do
      it "retorna 404" do
        delete comentario_path(-1), headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
