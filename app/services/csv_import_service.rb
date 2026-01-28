require 'csv'

class CsvImportService
  def initialize(file)
    @file = file
  end

  def call
    rows = []
    # Open the file, handling potential BOM and encoding
    # Ensuring headers are normalized to strings
    CSV.foreach(@file.path, headers: true, encoding: 'bom|utf-8') do |row|
      # Convert row to hash and strip whitespace from values
      row_hash = row.to_h.transform_values { |v| v&.strip }
      rows << row_hash
    end
    rows
  rescue CSV::MalformedCSVError => e
    Rails.logger.error "CSV Parse Error: #{e.message}"
    []
  end
end
