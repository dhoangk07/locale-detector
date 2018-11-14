set :stage, :production
server '206.189.152.101', user: 'deploy', roles: %w{web app db}
