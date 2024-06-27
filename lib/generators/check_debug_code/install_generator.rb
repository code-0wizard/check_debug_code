require 'rails/generators'

module CheckDebugCode
  class InstallGenerator < Rails::Generators::Base
    def enable_in_development
      environment(nil, env: 'development') do
        <<~FILE
          config.x.check_debug_code.target_file_extensions = ['rb', 'js', 'erb']
          config.x.check_debug_code.target_strings         = ['console.log', 'debugger']
        FILE
      end

    end

    def enable_in_test
      return unless yes?('Would you like to enable check_debug_code in test environment? (y/n)')

      environment(nil, env: 'test') do
        <<~FILE
          config.x.check_debug_code.target_file_extensions = ['rb', 'js', 'erb']
          config.x.check_debug_code.target_strings         = ['console.log', 'debugger']
        FILE
      end
    end

  end
end
