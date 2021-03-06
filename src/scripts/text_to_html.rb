class Action
  CSS_STYLES = %w[day-dream sage-brush petal moss flower-power paisley].freeze

  def initialize(text, index)
    @text = text
    @index = index
  end

  def to_html
    css = ("action-card #{custom_css} " + hashtags.map { |h| h.downcase }.join(' ')).strip
    action_html = augment(text_without_hashtags)
    "<div class='#{css}'>
  <div class='action-subtitle'>
    <h1>Tell Your Friends to</h1>
  </div>
  <div class='action-content'>
    <div>
      <h1><a href='#'>#{action_html}</a>
      </h1>
      <div class='action-phrase'>
        <p class='firstpar'>
          Would you use your voice, your body, your money, your time?
        </p>
        <p class='nextpar'>What particular causes will you get involved with?</p>
      </div>
    </div>
  </div>
</div>
"
  end

  def custom_css
    CSS_STYLES[@index % CSS_STYLES.length]
  end

  def persist
    filename = text_without_hashtags.split(' ')[0..4].join('_').gsub(/\W/, '').downcase + '.html'
    File.open('src/html_snippets/' + filename, 'w') { |f| f.write to_html }
  end

  private

  def text_without_hashtags
    @text.split(' ').reject { |word| word.start_with?('#') }.join(' ').chomp
  end

  # returns the hashtags parsed from the text without '#'
  def hashtags
    @text.split(' ').select { |word| word.start_with?('#') }.map { |word| word.gsub('#', '') }
  end

  def hashtag_html
    hashtags.map do |hashtag|
      "<a href='##{hashtag.downcase}'>##{hashtag}</a>"
    end.join("\n    ")
  end

  def augment(content)
    content.split(' ').map do |word|
      if word.include?('http')
        if word.include?('youtube.com')
          src = word.gsub('watch', 'embed')
          "<iframe width='560' height='315' src='#{src}' frameborder='0' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture' allowfullscreen></iframe>"
        else
          "<a target='_blank' href='#{word}'>#{word}</a>"
        end
      else
        word
      end
    end.join(' ')
  end
end

def load_actions
  path = File.join(File.dirname(__FILE__), 'actions.txt')
  @raw_text = File.read(path)
end

def extract_actions
  @actions = @raw_text.split("\n\n").reject { |t| t.strip.empty? }.map.with_index { |t, i| Action.new(t, i) }
end

def generate_html
  puts @actions.map { |t| t.to_html }.join
end

def generate_index
  # concat all the html snippets and merge into index.html.template
end

load_actions
extract_actions
generate_html
@actions.each { |t| t.persist }
generate_index
