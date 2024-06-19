require 'rails/generators'

module CheckDebugCode
  class InstallGenerator < Rails::Generators::Base
    def enable_in_development
      environment(nil, env: 'development') do
        <<-FILE
          config.after_initialize do
            Bullet.enable        = true
            Bullet.alert         = true
            Bullet.bullet_logger = true
            Bullet.console       = true
            Bullet.rails_logger  = true
            Bullet.add_footer    = true
          end
        FILE
      end
      say 'Enabled check_debug_code in config/environments/development.rb'
    end
  end
end
