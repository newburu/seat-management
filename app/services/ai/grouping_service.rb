module Ai
  class GroupingService
    MODELS = %w[gemini-2.0-flash gemini-flash-latest gemini-1.5-flash gemini-1.5-pro gemini-1.0-pro]

    def initialize(event, seats_per_group: nil)
      @event = event
      @participants = event.participants
      @seats_per_group = seats_per_group
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

      group_size_instruction = if @seats_per_group.present?
                                 "3. 各グループの人数は #{@seats_per_group} 人程度になるようにしてください。"
                               else
                                 "3. グループの数と各グループの人数は、自動的に最適化してください。"
                               end

      <<~PROMPT
        あなたはプロのイベントオーガナイザーです。以下の参加者を最適なチームにグループ分けしてください。
        
        参加者データ:
        #{participants_data}

        指示:
        1. 各参加者の属性を分析してください。
        2. バランスの取れた、あるいはテーマごとの一貫性のあるグループを作成してください（例：同じ趣味、スキルの多様性など）。
        #{group_size_instruction}
        4. 出力は必ず以下のスキーマに従った有効なJSONのみとしてください。
        5. グループ名（name）と理由（reason）は必ず日本語で出力してください。

        JSONスキーマ:
        {
          "groups": [
            {
              "name": "グループ名",
              "reason": "このグループ分けの理由",
              "members": ["名前1", "名前2"]
            }
          ]
        }
        6. 説明やMarkdownのフォーマット（```json など）を含めないでください。生のJSON文字列のみを出力してください。
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
          version: 'v1beta',
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
