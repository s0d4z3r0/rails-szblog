require 'rails_helper'

RSpec.describe "Posts API", type: :request do
  let!(:usuario) { Usuario.create!(nome: "Fulado", email: "fulano@email.com", password: "senha123", password_confirmation: "senha123") }
  let!(:postagem) { Post.create!(titulo: "Título", texto: "Texto do post.", usuario: usuario) }
  let!(:headers) { { "ACCEPT" => "application/json" } }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(usuario)
  end

  describe "GET /posts" do
    it "retorna todos os posts" do
      create_list(:post, 3)
      get "/posts", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Post.count)
    end
  end

  describe "GET /posts/:id" do
    context "quando existe o post" do
      it "retorna o post em JSON" do
        get post_path(postagem), headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["id"]).to eq(postagem.id)
        expect(json["titulo"]).to eq(postagem.titulo)
        expect(json["texto"]).to eq(postagem.texto)
        expect(json["usuario_id"]).to eq(usuario.id)
      end
    end

    context "quando o post não existe" do
      it "retorna 404" do
        get "/posts/99999"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /posts" do
    context "com dados válidos" do
      it "cria um novo post" do
        expect {
          post posts_path,
          params: {
            post: {
              titulo: "Novo Post",
              texto: "Novo texto do post"
            }
          },
          headers: headers
        }.to change(Post, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["titulo"]).to eq("Novo Post")
        expect(json["texto"]).to eq("Novo texto do post")
      end
    end

    context "com dados inválidos" do
      it "não cria o post e retorna erros" do
        post posts_path,
        params: { post: { titulo: "", texto: "" } },
        headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key("titulo")
        expect(json).to have_key("texto")
      end
    end
  end

  describe "PATCH /posts/:id" do
    context "com dados válidos" do
      it "atualiza o post" do
        patch post_path(postagem),
        params: { post: { titulo: "Título Atualizado" } },
        headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["titulo"]).to eq("Título Atualizado")
      end
    end

    context "com dados inválidos" do
      it "não atualiza o post e retorna erros" do
        patch post_path(postagem),
        params: { post: { titulo: "" } },
        headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key("titulo")
      end
    end

    context "quando o post pertence a outro usuário" do
      let(:outro_usuario) { Usuario.create!(nome: "Ciclano", email: "ciclano@email.com", password: "senha456", password_confirmation: "senha456") }
      let(:post_do_ciclano) { Post.create!(titulo: "Titulo do Texto do Ciclano", texto: "Texto do ciclano", usuario: outro_usuario) }
        it "retorna 403 ao tentar atualizar" do
          patch post_path(post_do_ciclano),
          params: { post: { titulo: "Hackeado" } },
          headers: headers

          expect(response).to have_http_status(:forbidden)
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Acesso não autorizado.")
        end
    end
  end

  describe "DELETE /posts/:id" do
    it "exclui o post" do
      expect {
        delete post_path(postagem), headers: headers
    }.to change(Post, :count).by(-1)

    expect(response).to have_http_status(:see_other).or have_http_status(:no_content)
    end

    context "quando o post pertence a outro usuário" do
      let(:outro_usuario) { Usuario.create!(nome: "Ciclano", email: "ciclano@email.com", password: "senha456", password_confirmation: "senha456") }
      let(:post_do_ciclano) { Post.create!(titulo: "Titulo do Texto do Ciclano", texto: "Texto do ciclano", usuario: outro_usuario) }

        it "retorna 403 ao tentar excluir" do
          delete post_path(post_do_ciclano), headers: headers
          expect(response).to have_http_status(:forbidden)
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Acesso não autorizado.")
        end
    end
  end
end
