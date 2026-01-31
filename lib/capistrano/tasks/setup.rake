namespace :deploy do
  desc 'Upload config files to shared/config'
  task :upload_configs do
    on roles(:app) do
      # Create config directory if it doesn't exist
      execute :mkdir, '-p', "#{shared_path}/config"

      # Upload config/database.yml
      if File.exist?('config/database.yml')
        upload!('config/database.yml', "#{shared_path}/config/database.yml")
      end

      # Upload config/master.key
      if File.exist?('config/master.key')
        upload!('config/master.key', "#{shared_path}/config/master.key")
      end

      # Upload .env (prefer .env.production if exists)
      if File.exist?('.env.production')
        upload!('.env.production', "#{shared_path}/.env")
      elsif File.exist?('.env')
        upload!('.env', "#{shared_path}/.env")
      end
    end
  end

  # Run this task before checking linked files
  before 'deploy:check:linked_files', 'deploy:upload_configs'
end
