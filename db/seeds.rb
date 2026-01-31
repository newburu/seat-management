# User creation (assuming Devise or similar)
user = User.first_or_create!(
  email: "guest@example.com",
  password: "password",
  password_confirmation: "password"
)

# Event creation
event = Event.find_or_create_by!(id: 1) do |e|
  e.name = "テストイベント2026（レスポンシブ確認用）"
  e.user = user
end

# Clear existing participants to avoid duplicates if re-running
event.participants.destroy_all

# Participant variations
participants_data = []

# StrengthsFinder 34 Themes (Japanese)
strengths_themes = %w[
  アレンジ 運命思考 回復志向 学習欲 活発性
  共感性 競争性 規律性 原点思考 公平性
  個別化 コミュニケーション 最上志向 自我 自己確信
  社交性 収集心 指令性 慎重さ 信念
  親密性 成長促進 責任感 戦略性 達成欲
  着想 調和性 適応性 内省 分析思考
  抱行性 ポジティブ 未来志向 目標志向
]

# Random generation for 20 participants
20.times do |i|
  last_name = %w[伊藤 山本 中村 小林 加藤 吉田 山田 佐々木 山口 松本 井上 木村 林 清水 山崎].sample
  first_name = %w[健太 拓也 大輔 誠 直人 恵 美咲 遥 香織 奈緒 翔太 陽菜 結衣 颯太 陸].sample
  
  # Select 5 random strengths
  my_strengths = strengths_themes.sample(5)
  properties = {}
  
  my_strengths.each_with_index do |strength, index|
    properties["資質#{index + 1}"] = strength
  end
  
  participants_data << {
    name: "#{last_name} #{first_name}",
    properties: properties
  }
end


# Create records
participants_data.each do |data|
  event.participants.create!(
    name: data[:name],
    properties: data[:properties]
  )
end

puts "Seed data created successfully!"
puts "Event ID: #{event.id}"
puts "Event Name: #{event.name}"
puts "Participants created: #{event.participants.count}"
