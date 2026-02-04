# config valid for current version and patch releases of Capistrano
lock "~> 3.20.0"

set :application, "seat-management"
set :repo_url, "git@github.com:newburu/seat-management.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, "master"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/seat-management"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml", ".env", "config/master.key"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "storage"

# rbenv
set :rbenv_type, :user
set :rbenv_ruby, '4.0.0' # Adjust to actual ruby version if different

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :puma_systemctl_user, :user
set :puma_service_unit_name, "seat-management_puma_production"
set :puma_conf, "#{current_path}/config/puma.rb"

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke! 'puma:restart'
    end
  end

  after :publishing, :restart
end

# Force clean assets before precompilation to ensure fresh Tailwind build
namespace :deploy do
  namespace :assets do
    desc 'Clobber assets'
    task :clobber do
      on roles(:web) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            # Use fetch(:rake) to leverage Capistrano's Rake mapping, or fallback to 'rake'
            # However, since we are inside `within`, we should likely use the bundle prefix if configured, 
            # but standard capistrano-rails usage is often just `execute :rake ...` which maps to `bundle exec rake`
            execute :rake, 'assets:clobber'
          end
        end
      end
    end
  end
end

before 'deploy:assets:precompile', 'deploy:assets:clobber'
