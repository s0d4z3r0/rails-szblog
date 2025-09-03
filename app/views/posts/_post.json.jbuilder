json.extract! post, :id, :titulo, :texto, :usuario_id, :created_at, :updated_at
json.url post_url(post, format: :json)
