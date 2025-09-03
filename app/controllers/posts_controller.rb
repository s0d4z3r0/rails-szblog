class PostsController < ApplicationController
  before_action :autenticar_usuario!
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :autoriza_usuario!, only: %i[ edit update destroy ]
  rescue_from ActiveRecord::RecordNotFound, with: :registro_nao_encontrado

  # GET /posts or /posts.json
  def index
    @posts = Post.all

    respond_to do |format|
      format.html
      format.json { render json: @posts }
    end
  end

  # GET /posts/1 or /posts/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: @post }
    end
  end

  # GET /posts/new
  def new
    @post = Post.new

    respond_to do |format|
      format.html
      format.json { render json: @post }
    end
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = current_usuario.posts.build(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post criado com sucesso." }
        format.json { render :show, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post atualizado com sucesso." }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: "Post apagado com sucesso." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:titulo, :texto)
    end

    def autoriza_usuario!
      return if @post.usuario == current_usuario

      respond_to do |format|
      format.html { redirect_to root_path, alert: "Acesso não autorizado." }
      format.json { render json: { error: "Acesso não autorizado." }, status: :forbidden }
      end
    end

    def registro_nao_encontrado
      respond_to do |format|
        format.html { redirect_to posts_path, alert: "Post não encontrado." }
        format.json { render json: { error: "Post não encontrado" }, status: :not_found }
      end
    end
end
