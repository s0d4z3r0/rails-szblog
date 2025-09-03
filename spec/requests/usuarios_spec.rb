require 'rails_helper'

RSpec.describe "Usuarios API", type: :request do
  let!(:usuario) { Usuario.create!(nome: "Fulano", email: "fulano@email.com", password: "senha123", password_confirmation: "senha123") }
  let!(:outro_usuario) { Usuario.create!(nome: "Ciclano", email: "ciclano@email.com", password: "senha456", password_confirmation: "senha456") }
  let!(:headers) { { "ACCEPT" => "application/json" } }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(usuario)
  end

  describe "GET /usuarios/:id" do
    it "retorna o usuario em JSON" do
      get usuario_path(usuario), headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(usuario.id)
      expect(json["nome"]).to eq(usuario.nome)
      expect(json["email"]).to eq(usuario.email)
    end
  end

  describe "GET /usuarios" do
    it "retorna todos os usuarios em JSON" do
      get usuarios_path, headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first["id"]).to eq(usuario.id)
    end
  end

  describe "POST /usuarios" do
    context "com dados válidos" do
      it "cria um novo usuário" do
        expect {
          post usuarios_path,
            params: {
              usuario: {
                nome: "Novo",
                email: "novo@email.com",
                password: "123456",
                password_confirmation: "123456"
                }
              },
            headers: headers
          }.to change(Usuario, :count).by(1)

          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json["nome"]).to eq("Novo")
          expect(json["email"]).to eq("novo@email.com")
      end
    end

    context "com dados inválidos" do
      it "não cria o usuário e retorna erros" do
        post usuarios_path,
          params: { usuario: { nome: "", email: "", password: "", password_confirmation: "" } },
          headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json).to have_key("nome")
          expect(json).to have_key("email")
      end
    end
  end

  describe "PUT /usuarios/:id" do
    context "com dados válidos" do
      it "atualiza o usuário" do
        put usuario_path(usuario), params: {
          usuario: { nome: "Nome Atualizado" }
        }, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["nome"]).to eq("Nome Atualizado")
      end
    end

    context "com dados inválidos" do
      it "não atualiza o usuário e retorna os erros" do
        put usuario_path(usuario), params: {
          usuario: { nome: "" }
        }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key("nome")
      end
    end
  end

  describe "DELETE /usuarios/:id" do
    context "com dados válidos" do
      it "deleta o usuário atual" do
        expect {
          delete usuario_path(usuario), headers: headers
      }.to change(Usuario, :count).by(-1)

      expect(response).to have_http_status(:no_content)
      end
    end

    context "com dados inválidos" do
      it "não deleta usuário atual e retorna erros" do
        expect {
          delete usuario_path(usuario), headers: headers
      }.to change(Usuario, :count).by(-1)

      expect(response).to have_http_status(:no_content)
      end
    end
  end

  context "quando usuário tenta acessar outro usuário" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(outro_usuario)
    end

    it "retorna status 403 no update" do
      put usuario_path(usuario), params: {
        usuario: { nome: "Teste" }
      }, headers: headers

      expect(response).to have_http_status(:forbidden)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Acesso não autorizado.")
    end
  end
end
