# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?

before do
  @chapters_list = File.readlines('data/toc.txt')
end

# view helpers
helpers do
  def in_paragraph(chapter_content)
    chapter_content.split("\n\n").map.with_index do |para, index|
      "<p id=paragraph#{index}>#{para}</p>"
    end.join
  end

  def highlight(chapter_content, query)
    chapter_content.gsub(query.to_s, "<strong>#{query}</strong>")
  end
end

#helper methods
def each_chapter
  @chapters_list.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

def chapters_matching_query(query)
  results = []

  return results unless query

  each_chapter do |number, name, contents|
    matches = {}

    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end

    results << { number:, name:, paragraphs: matches } if matches.any?
  end

  results
end


get '/' do
  erb :home
end

get '/chapters/:num' do
  @chapter_number = params[:num].to_i

  redirect '/' unless (1..@chapters_list.size).include?(@chapter_number)

  @chapter_content = File.read("./data/chp#{@chapter_number}.txt")
  erb :chapter
end

get '/search' do
  query = params[:query]

  @query_results_chapters_list = chapters_matching_query(query)

  erb :search
end
