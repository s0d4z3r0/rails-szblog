class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_usuario, :usuario_logado?

  def current_usuario
    @current_usuario ||= Usuario.find_by(id: session[:usuario_id])
  end

  def usuario_logado?
    current_usuario.present?
  end

  def autenticar_usuario!
    unless current_usuario
      respond_to do |format|
           format.json { render json: { error: "Usuário não autenticado." }, status: :unauthorized }
           format.html { redirect_to login_path }
      end
    end
    usuario_logado?
  end
end
