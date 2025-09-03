class UsuariosController < ApplicationController
  before_action :autenticar_usuario!, except: [ :new, :create ]
  before_action :set_usuario, only: %i[ show edit update destroy ]

  # GET /usuarios or /usuarios.json
  def index
    @usuarios = Usuario.all
    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /usuarios/1 or /usuarios/1.json
  def show
    @usuario = Usuario.find(params[:id])
    unless current_usuario == @usuario
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Acesso não autorizado." }
        format.json { render json: { error: "Acesso não autorizado." }, status: :forbidden }
      end
    end
  end

  # GET /usuarios/new
  def new
    @usuario = Usuario.new
  end

  # GET /usuarios/1/edit
  def edit
    unless current_usuario == @usuario
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  # POST /usuarios or /usuarios.json
  def create
    @usuario = Usuario.new(usuario_params)

    respond_to do |format|
      if @usuario.save
        session[:usuario_id] = @usuario.id
        format.html { redirect_to root_path, notice: "Usuário criado com sucesso." }
        format.json { render :show, status: :created, location: @usuario }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @usuario.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /usuarios/1 or /usuarios/1.json
  def update
    unless current_usuario == @usuario
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Acesso não autorizado." }
        format.json { render json: { error: "Acesso não autorizado." }, status: :forbidden }
      end
      return
    end

    respond_to do |format|
      if @usuario.update(usuario_params)
        format.html { redirect_to @usuario, notice: "Usuário atualizado com sucesso." }
        format.json { render json: @usuario }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @usuario.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /usuarios/1 or /usuarios/1.json
  def destroy
    unless current_usuario == @usuario
      redirect_to root_path, alert: "Acesso não autorizado."
    end
    @usuario.destroy!

    respond_to do |format|
      session[:usuario_id] = nil if current_usuario == @usuario
      format.html { redirect_to root_path, status: :see_other, notice: "Usuário apagado com sucesso." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_usuario
      @usuario = Usuario.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def usuario_params
      params.require(:usuario).permit(:nome, :email, :password, :password_confirmation)
    end
end
