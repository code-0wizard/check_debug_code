module CheckDebugCode
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      matching_files = search_files_for_strings
      # log_to_console(matching_files)
      if !matching_files.nil?
        log_to_rails(matching_files) if Rails.configuration.x.check_debug_code.logger
      end

      status, headers, response = @app.call(env)
      response = append_to_response_footer(response, matching_files)

      [status, headers, response]
    end

    private

    def search_files_for_strings
      target_file_extensions = Rails.configuration.x.check_debug_code.target_file_extensions
      target_strings = Rails.configuration.x.check_debug_code.target_strings
      excluded_files = [
                          "/config/environments/development.rb", 
                          "/config/environments/test.rb"
                        ]

      formatted_file_extensions = target_file_extensions.map { |ext| "--include='*.#{ext}'" }.join(' ')
      formatted_strings = target_strings.map { |str| "-e #{str}" }.join(' ') 

      result = `grep -rl  #{formatted_file_extensions} #{formatted_strings} '#{Rails.root.to_s}'`
      formatted_result = result.split("\n").map { |file| file.sub("#{Rails.root}/", '') }
      filtered_result = formatted_result.reject { |file| excluded_files.include?(file) }
      filtered_result
    end

    # def log_to_console(matching_files)
    #   Rails.logger.info "<script>console.log(#{matching_files.inspect});</script>"
    # end

    def log_to_rails(matching_files)
      Rails.logger.info "マッチしたファイルは: #{matching_files.join(', ')}"
    end

    def append_to_response_footer(response, matching_files)
      return response unless response.is_a?(Array)

      response_body = response.body.join
      response_body += "<footer>#{matching_files.join(', ')}</footer>"
      [response_body]
    end
  end
end
