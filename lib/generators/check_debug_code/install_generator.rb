require 'rails/generators'

module CheckDebugCode
  class InstallGenerator < Rails::Generators::Base
    def enable_in_development
      environment(nil, env: 'development') do
        <<~FILE
          config.target_file_extensions = ['rb', 'js', 'erb']
          config.target_strings         = ['console.log', 'debugger']
          config.rails_logger           = true
          config.console                = true
          config.add_footer             = true
        FILE
      end

    end

    def enable_in_test
      return unless yes?('Would you like to enable check_debug_code in test environment? (y/n)')

      environment(nil, env: 'test') do
        <<~FILE
          config.target_file_extensions = ['rb', 'js', 'erb']
          config.target_strings         = ['console.log', 'debugger']
          config.rails_logger           = true
          config.console                = true
          config.add_footer             = true
        FILE
      end
    end

  end
end
