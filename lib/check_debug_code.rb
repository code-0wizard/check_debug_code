module CheckDebugCode

  require "check_debug_code/version"

  def execute_check
    matching_file_data = find_matching_files
    # log_to_console(matching_files)
    if !matching_file_data.nil?
      log_to_rails(matching_file_data) if Rails.configuration.x.check_debug_code.logger
    end
  end

  def find_matching_files
    target_file_extensions = Rails.configuration.x.check_debug_code.target_file_extensions
    target_strings = Rails.configuration.x.check_debug_code.target_strings

    formatted_file_extensions = format_file_extensions(target_file_extensions)
    formatted_strings = format_strings(target_strings)
    rails_root_path = Rails.root.to_s

    result = `grep -rn  #{formatted_file_extensions} #{formatted_strings} '#{rails_root_path}'`

    filtered_results = filter_results(result)

    format_results(filtered_results, rails_root_path)
  end

  def format_file_extensions(extensions)
    extensions.map { |ext| "--include='*.#{ext}'" }.join(' ')
  end

  def format_strings(strings)
    strings.map { |str| "-e #{str}" }.join(' ')
  end

  def filter_results(result, excluded_files)
    excluded_files = [
      "config/environments/development.rb", 
      "config/environments/test.rb"
    ]
    result.split("\n").reject do |line|
      excluded_files.any? { |excluded| line.include?(excluded) }
    end
  end

  def format_results(filtered_results, rails_root_path)
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
    Rails.logger.info "\n<check_debug_code>\n[\n #{data.join(",\n ")} \n]\n<check_debug_code>\n"
  end
end
