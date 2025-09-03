json.id @usuario.id
json.nome @usuario.nome
json.email @usuario.email

json.partial! "usuarios/usuario", usuario: @usuario
