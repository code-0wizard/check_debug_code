module CheckDebugCode
  require "check_debug_code/version"

  def check_for_debug_code
    matching_file_data = find_debug_code
    log_to_rails(matching_file_data) if matching_file_data && Rails.configuration.x.check_debug_code.logger
  end

  private

  def find_debug_code
    result = run_grep
    filtered_results = filter_results(result)
    format_results(filtered_results)
  end

  def run_grep
    target_file_extensions = Rails.configuration.x.check_debug_code.target_file_extensions
    target_strings = Rails.configuration.x.check_debug_code.target_strings
    formatted_file_extensions = target_file_extensions.map { |ext| "--include='*.#{ext}'" }.join(' ')
    formatted_strings = target_strings.map { |str| "-e #{str}" }.join(' ')
    rails_root_path = Rails.root.to_s

    `grep -rn #{formatted_file_extensions} #{formatted_strings} '#{rails_root_path}'`
  end

  def filter_results(result)
    excluded_files = [
      "config/environments/development.rb",
      "config/environments/test.rb"
    ]
    result.split("\n").reject do |line|
      excluded_files.any? { |excluded| line.include?(excluded) }
    end
  end

  def format_results(filtered_results)
    rails_root_path = Rails.root.to_s
    filtered_results.map do |line|
      file, line_number, matched_string = line.split(':', 3)
      relative_path = file.sub("#{rails_root_path}/", '')
      {
        file: relative_path,
        line: line_number.to_i,
        matching_string: matched_string.strip
      }
    end
  end

  def log_to_rails(data)
    formatted_data = data.map { |entry| entry.to_s }.join(",\n ")
    Rails.logger.info "\n<check_debug_code>\n[\n #{formatted_data} \n]\n<check_debug_code>\n"
  end
end
