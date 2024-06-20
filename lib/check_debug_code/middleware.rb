module CheckDebugCode
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      matching_file_data = search_file
      # log_to_console(matching_files)
      if !matching_file_data.nil?
        log_to_rails(matching_file_data) if Rails.configuration.x.check_debug_code.logger
      end
      status, headers, response = @app.call(env)
      response = append_to_response_footer(response, matching_file_data)
      [status, headers, response]
      puts response
    end

    private

    def search_file
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
          file: relative_path,
          line: line_number.to_i,
          matching_string: matched_string.strip
        }
      end
    end

    # def log_to_console(matching_files)
    #   Rails.logger.info "<script>console.log(#{matching_files.inspect});</script>"
    # end

    def log_to_rails(data)
      Rails.logger.info "\n<check_debug_code>\n[\n #{data.join(",\n ")} \n]\n<check_debug_code>\n"
    end

    def append_to_response_footer(response, matching_files)
      return response unless response.is_a?(Array)

      response_body = response.body.join
      response_body += "<footer>#{matching_files.join(', ')}</footer>"
      [response_body]
    end
  end
end
