module Ai
  class GroupingService
    MODELS = %w[gemini-1.5-flash gemini-1.5-pro gemini-1.0-pro]

    def initialize(event)
      @event = event
      @participants = event.participants
    end

    def call
      return [] if @participants.empty?

      # Mock response if API key is missing
      if ENV['GOOGLE_API_KEY'].blank?
        Rails.logger.warn "Ai::GroupingService: GOOGLE_API_KEY is missing. Returning mock response."
        return mock_response
      end

      prompt = build_prompt
      response_json = call_with_fallback(prompt)
      parse_response(response_json)
    end

    private

    def build_prompt
      participants_data = @participants.map do |p|
        { name: p.name }.merge(p.properties || {})
      end.to_json

      <<~PROMPT
        You are an expert event organizer. Your task is to group the following participants into optimal teams.
        
        Participants Data:
        #{participants_data}

        Instructions:
        1. Analyze the properties of each participant.
        2. Create groups that are balanced or thematically consistent (e.g., same hobbies, diverse skills).
        3. Determine the optimal number of groups and members per group automatically.
        4. Output MUST be valid JSON only, following this schema:
        {
          "groups": [
            {
              "name": "Group Name",
              "reason": "Reason for this grouping",
              "members": ["Name1", "Name2"]
            }
          ]
        }
        5. Do not include any explanations or markdown formatting (like ```json). Just the raw JSON string.
      PROMPT
    end

    def call_with_fallback(prompt)
      MODELS.each do |model|
        begin
          Rails.logger.info "Ai::GroupingService: Trying model #{model}..."
          result = call_api(model, prompt)
          return result if result.present?
        rescue => e
          Rails.logger.warn "Ai::GroupingService: Model #{model} failed: #{e.message}"
          next
        end
      end
      raise "Ai::GroupingService: All models failed."
    end

    def call_api(model, prompt)
      client = Gemini.new(
        credentials: {
          service: 'generative-language-api',
          api_key: ENV['GOOGLE_API_KEY']
        },
        options: { model: model, server_sent_events: false }
      )

      result = client.generate_content({
        contents: { 
          role: 'user', 
          parts: { text: prompt } 
        }
      })
      
      # Extract text from response structure
      # Response structure roughly: [{'candidates' => [{'content' => {'parts' => [{'text' => '...'}]}}]}]
      # gemini-ai gem might return parsed JSON or raw hash.
      
      candidates = result&.dig('candidates') || result&.first&.dig('candidates')
      
      if candidates.blank?
        # Attempt to handle different response structure or error in body
        raise "Invalid API response: #{result.inspect}"
      end
      
      candidates.first.dig('content', 'parts', 0, 'text')
    end

    def parse_response(json_string)
      # Clean up markdown code blocks if present despite instructions
      clean_json = json_string.gsub(/```json/, '').gsub(/```/, '').strip
      JSON.parse(clean_json)
    rescue JSON::ParserError => e
      Rails.logger.error "Ai::GroupingService: JSON Parse Error: #{e.message}. Raw: #{json_string}"
      raise e
    end

    def mock_response
      {
        "groups" => [
          {
            "name" => "グループA (モック)",
            "reason" => "APIキー未設定時のモックデータです。",
            "members" => @participants.map(&:name).take((@participants.size / 2.0).ceil)
          },
          {
            "name" => "グループB (モック)",
            "reason" => "残りのメンバーです。",
            "members" => @participants.map(&:name).drop((@participants.size / 2.0).ceil)
          }
        ]
      }
    end
  end
end
