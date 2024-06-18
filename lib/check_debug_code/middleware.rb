module CheckDebugCode
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Rails.logger.info "hogehoge"
      directory = Rails.root.to_s
      matching_files = search_console_log_with_grep(directory)

      # log_to_console(matching_files)
      log_to_rails(matching_files)

      status, headers, response = @app.call(env)
      response = append_to_response_footer(response, matching_files)

      [status, headers, response]
    end

    def self.hoge
      p 'hoge'
    end

    private

    def search_console_log_with_grep(directory)
      result = `grep -rl 'console.log' #{directory}`
      result.split("\n")
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
