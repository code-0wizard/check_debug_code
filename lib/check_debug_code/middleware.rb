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
                          "config/environments/development.rb", 
                          "config/environments/test.rb"
                        ]

      formatted_file_extensions = target_file_extensions.map { |ext| "--include='*.#{ext}'" }.join(' ')
      formatted_strings = target_strings.map { |str| "-e #{str}" }.join(' ')
      rails_root_path = Rails.root.to_s

      result = `grep -rn  #{formatted_file_extensions} #{formatted_strings} '#{rails_root_path}'`

      filtered_results = result.split("\n").reject do |line|
        excluded_files.any? { |excluded| line.include?(excluded) }
      end

      formatted_results = filtered_results.map do |line|
        file, line_number, matched_string = line.split(':', 3)
        relative_path = file.sub("#{rails_root_path}/", '')
        {
          file_name: relative_path,
          number_of_lines: line_number.to_i,
          matching_string: matched_string.strip
        }
      end

      puts filtered_results
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
