class ComentariosController < ApplicationController
  before_action :autenticar_usuario!
  before_action :set_comentario, only: %i[ show edit update destroy ]
  before_action :autoriza_usuario!, only: %i[ edit update destroy ]

  # GET /comentarios or /comentarios.json
  def index
    @comentarios = Comentario.all
    respond_to do |format|
      format.html
      format.json { render json: @comentarios }
    end
  end

  # GET /comentarios/1 or /comentarios/1.json
  def show
    respond_to do |format|
      format.html
      format.json do
        if @comentario
          render json: @comentario, status: :ok
        else
          render json: { error: "Comentário não encontrado." }, status: :not_found
        end
      end
    end
  end

  # GET /comentarios/new
  def new
    @comentario = Comentario.new
    @comentario.post_id = params[:post_id] if params[:post_id].present?
    load_posts_grouped
    respond_to do |format|
      format.html
      format.json { render json: @comentario }
    end
  end

  # GET /comentarios/1/edit
  def edit
    load_posts_grouped
    respond_to do |format|
      format.html
      format.json { render json: @comentario }
    end
  end

  # POST /comentarios or /comentarios.json
  def create
    @comentario = current_usuario.comentarios.build(comentario_params)

    respond_to do |format|
      if @comentario.save
        format.html { redirect_to @comentario, notice: "Comentário criado com sucesso." }
        format.json { render json: @comentario, status: :created }
      else
        load_posts_grouped
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comentario.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comentarios/1 or /comentarios/1.json
  def update
    respond_to do |format|
      if @comentario.update(comentario_params)
        format.html { redirect_to @comentario, notice: "Comentário atualizado com sucesso." }
        format.json { render json: @comentario, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comentario.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comentarios/1 or /comentarios/1.json
  def destroy
    @comentario.destroy!

    respond_to do |format|
      format.html { redirect_to comentarios_path, status: :see_other, notice: "Comentário apagado com sucesso." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comentario
      @comentario = Comentario.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html { redirect_to comentarios_path, alert: "Comentário não encontrado." }
        format.json { render json: { error: "Comentário não encontrado." }, status: :not_found }
      end
    end

    # Only allow a list of trusted parameters through.
    def comentario_params
      params.require(:comentario).permit(:comentario, :post_id)
    end

    def load_posts_grouped
      @posts_grouped = Usuario.includes(:posts).each_with_object({}) do |usuario, hash|
        hash[usuario.nome] = usuario.posts.map { |post| [ post.titulo, post.id ] }
      end
    end

    def autoriza_usuario!
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Comentário não encontrado." }
        format.json { render json: { error: "Comentário não encontrado." }, status: :not_found }
      end
      if current_usuario != @comentario.usuario
        respond_to do |format|
          format.html { redirect_to root_path, alert: "Acesso não autorizado." }
          format.json { render json: { error: "Acesso não autorizado." }, status: :forbidden }
        end
      end
    end
end
