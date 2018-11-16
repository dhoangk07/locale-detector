lock "~> 3.11.0"

set :application, "locale-detector"
set :repo_url, "https://github.com/dhoangk07/locale-detector.git"

set :passenger_restart_with_touch, true
set :deploy_to, "/home/deploy/locale-detector"

set :workers, { "clone_queue" => 1, "delete_folder_queue" => 3, "fetch_description_queue" => 1 }
set :resque_environment_task, true
after "deploy:restart", "resque:restart"

set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

