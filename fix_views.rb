require 'fileutils'

Dir.glob("app/views/**/*.html.erb").each do |file|
  next if file == "app/views/layouts/application.html.erb" || file == "app/views/layouts/mailer.html.erb" || file.include?("_candidate_date_fields")
  
  content = File.read(file)
  
  # Extract title
  title_match = content.match(/<title>(.*?)<\/title>/)
  title = title_match ? title_match[1] : ""
  
  # Special titles based on file if title has ERB
  if file.include?("result.html.erb")
    title = "<%= @event.title %> - 集計結果 | らくスケ"
  elsif file.include?("attendances/new.html.erb")
    title = "<%= @event.title %> - らくスケ 回答ページ"
  end

  # Remove <!DOCTYPE html>, <html>, <head>...</head>
  content.gsub!(/<!DOCTYPE html>\s*<html[^>]*>\s*<head>.*?<\/head>\s*/m, "")
  
  # Remove <body ...>
  body_match = content.match(/<body[^>]*>/)
  body_class = body_match ? body_match[0].match(/class="(.*?)"/)&.[](1) : ""
  content.gsub!(/<body[^>]*>\s*/m, "")
  
  # Remove </body></html>
  content.gsub!(/<\/body>\s*<\/html>\s*/m, "")
  
  # Prepend content_for :title
  if title && !title.empty?
    content = "<% content_for :title, \"#{title.gsub('"', '\"')}\" %>\n" + content
  end
  
  # Add body class to content_for :body_class if needed, or just let layout handle it
  File.write(file, content)
end
