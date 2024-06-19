module CheckDebugCode
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      matching_files = search_files_for_strings

      # log_to_console(matching_files)
      # log_to_rails(matching_files)

      status, headers, response = @app.call(env)
      response = append_to_response_footer(response, matching_files)

      [status, headers, response]
    end

    def self.grep
      require 'benchmark'
      result = Benchmark.realtime do
        target_file_extensions = ['rb', 'js', 'erb']
        target_strings = ['console.log', 'debugger']
        include_extensions = target_file_extensions.map { |ext| "--include=*.#{ext}" }.join(' ')
        search_patterns = target_strings.map { |str| "-e #{str}" }.join(' ')
        result = `grep -rl  #{include_extensions} #{search_patterns} '#{Rails.root.to_s}'`
        puts result.split("\n")
      end
      puts "処理概要 #{result}s"
    end

    private

    def search_files_for_strings
      target_file_extensions = Rails.application.config.check_debug_code.target_file_extensions
      Rails.logger.info "#{target_file_extensions}"
      target_strings = ['console.log', 'debugger']
      include_extensions = target_file_extensions.map { |ext| "--include=*.#{ext}" }.join(' ')
      search_patterns = target_strings.map { |str| "-e #{str}" }.join(' ')
      result = `grep -rl  #{include_extensions} #{search_patterns} '#{Rails.root.to_s}'`
      # result.split("\n")
      Rails.logger.info "#{result}"
    end

    # def log_to_console(matching_files)
    #   Rails.logger.info "<script>console.log(#{matching_files.inspect});</script>"
    # end

    def log_to_rails(matching_files)
      Rails.logger.info "Matching files: #{matching_files.join(', ')}"
    end

    def append_to_response_footer(response, matching_files)
      return response unless response.is_a?(Array)

      response_body = response.body.join
      response_body += "<footer>#{matching_files.join(', ')}</footer>"
      [response_body]
    end
  end
end
