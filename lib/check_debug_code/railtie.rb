module CheckDebugCode
  class Railtie < ::Rails::Railtie
    initializer "check_debug_code.configure_rails_initialization" do |app|
      app.middleware.use CheckDebugCode::Middleware

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
