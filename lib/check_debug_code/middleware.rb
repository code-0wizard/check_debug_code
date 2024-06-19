module CheckDebugCode
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      matching_files = search_files_for_strings

      # log_to_console(matching_files)
      if !matching_files.nil?
        log_to_rails(matching_files) if  Rails.configuration.x.check_debug_code.logger
      end

      status, headers, response = @app.call(env)
      response = append_to_response_footer(response, matching_files)

      [status, headers, response]
    end

    private

    def search_files_for_strings
      require 'benchmark'
      time = Benchmark.realtime do
        target_file_extensions = Rails.configuration.x.check_debug_code.target_file_extensions
        target_strings = Rails.configuration.x.check_debug_code.target_strings
        include_extensions = target_file_extensions.map { |ext| "--include=*.#{ext}" }.join(' ')
        search_patterns = target_strings.map { |str| "-e #{str}" }.join(' ')
        Rails.logger.info "include_extensions: #{include_extensions}"
        Rails.logger.info "search_patterns: #{search_patterns}"
        result = `grep -rl  #{include_extensions} #{search_patterns} '#{Rails.root.to_s}'`
        result.split("\n")
      end
      puts "処理概要 #{time}s"
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
