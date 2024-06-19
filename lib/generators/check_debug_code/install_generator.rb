require 'rails/generators'

module CheckDebugCode
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def create_initializer_file
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

    end
  end
end
