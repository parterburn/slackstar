module ApplicationHelper
  def format_text(text)
    Rinku.auto_link(simple_format(Slack::Messages::Formatting.unescape(text)), :all, 'target="_blank"').html_safe
  end
end
