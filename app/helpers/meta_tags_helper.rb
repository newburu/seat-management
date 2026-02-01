module MetaTagsHelper
  def default_meta_tags
    {
      site: 'Musubi',
      title: 'AIで、最適な座席を瞬時にデザイン',
      reverse: true,
      separator: '|',
      description: 'Musubiは、イベントやワークショップの座席配置を自動で最適化します。「属性の分散」「仲良しグループの維持」など、複雑な条件もAIにお任せ。',
      keywords: '席替え, AI, 座席表, 自動生成, イベント, ワークショップ',
      canonical: request.original_url,
      noindex: !Rails.env.production?,
      icon: [
        { href: image_url('favicon.png') },
        { href: image_url('favicon.png'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/png' },
      ],
      og: {
        site_name: 'Musubi',
        title: 'AIで、最適な座席を瞬時にデザイン',
        description: 'Musubiは、イベントやワークショップの座席配置を自動で最適化します。「属性の分散」「仲良しグループの維持」など、複雑な条件もAIにお任せ。',
        type: 'website',
        url: request.original_url,
        image: image_url('ogp.png'),
        locale: 'ja_JP',
      },
      twitter: {
        card: 'summary_large_image',
        site: '@newburu', # Replace with actual account if any
      }
    }
  end
end
