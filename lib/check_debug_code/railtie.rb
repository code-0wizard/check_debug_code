module CheckDebugCode
  class Railtie < ::Rails::Railtie
    initializer "check_debug_code.configure_rails_initialization" do |app|
      app.middleware.use CheckDebugCode::Middleware

      Rails.logger.info "ホゲホゲ"
      
      config.after_initialize do
        unless Rails.env.production?
          CheckDebugCode::InstallGenerator.start
        end
      end
    end
  end
end
