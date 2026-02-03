server "163.44.118.141", user: "rails", roles: %w{app db web}

# Custom SSH Options
# ==================
set :ssh_options, {
  forward_agent: true,
  auth_methods: %w(publickey),
  keys: %w(~/.ssh/rails-server) # Adjust if you use a different key
}
