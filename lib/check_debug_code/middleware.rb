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

    def self.find
      require 'benchmark'
        result = Benchmark.realtime do
        require 'find'

        matching_files = []
        directory = Rails.root.to_s

        Find.find(directry) do |path|
          next unless File.file?(path)
          next unless File.extname(path) == '.rb' || File.extname(path) == '.js'
      
          File.open(path, "r") do |file|
            file.each_line do |line|
              if line.include?('console.log')
                matching_files << path
                break
              end
            end
          end
        end
      
        matching_files
      end
      puts "処理概要 #{result}s"
    end

    def self.grep
      require 'benchmark'
      result = Benchmark.realtime do
        result = `grep -rl 'console.log' #{Rails.root.to_s}`
        result.split("\n")
      end
      puts "処理概要 #{result}s"
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
