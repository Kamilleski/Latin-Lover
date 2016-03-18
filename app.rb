require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'sinatra/base'
require 'net/http'
require 'uri'

configure :development, :test do
  require 'pry'
end

configure do
  set :views, 'app/views'
end

Dir[File.join(File.dirname(__FILE__), 'app', '**', '*.rb')].each do |file|
  require file
  also_reload file
end

#########################################
systran_key = "1560e28d-1b68-46f4-9c5c-da2e85584a22"
wordnik_key = "a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5"


get '/' do
  erb :'index'
end

post '/english?' do
  @word = params[:word]
  @french_word = get_translation(@word, 'fr', systran_key)
  @spanish_word = get_translation(@word, 'es', systran_key)
  @italian_word = get_translation(@word, 'it', systran_key)
  @latin_word = get_translation(@word, 'la', systran_key)

  @etymology = get_etymology(@word, wordnik_key)

  erb :'show'
end

####################################

def get_translation(word, language_code, key)
  url="https://api-platform.systran.net/translation/text/translate?input=#{word}&source=en&target=#{language_code}&withSource=false&withAnnotations=false&backTranslation=false&encoding=utf-8&key=#{key}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  parsed_data = JSON.parse(response)

  parsed_data["outputs"].first["output"]
  ##use parsed data
end

def get_etymology(word, key)
  url =  "http://api.wordnik.com:80/v4/word.json/#{word}/etymologies?useCanonical=true&api_key=#{key}
"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  parsed_data = JSON.parse(response)

  kamille = parsed_data[0][45..-9]
  first_quote = kamille.gsub("<ets>", "'").gsub("</ets>", "'")
  total_parse = first_quote.gsub("<er>", "'").gsub("</er>", "'")
  total_parse

end
