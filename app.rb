require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'sinatra/base'
require 'net/http'
require 'uri'
require 'nokogiri'

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
mer_web_key = "70bd7572-cdf0-4092-b17b-d20aca32e59f"


get '/' do
  erb :'index'
end

post '/english' do
  @word = params[:word]
  @french_word = get_translation(@word, 'fr', systran_key)
  @spanish_word = get_translation(@word, 'es', systran_key)
  @italian_word = get_translation(@word, 'it', systran_key)
  @latin_word = get_translation(@word, 'la', systran_key)

  @etymology = get_english_etymology(@word, mer_web_key)
  binding.pry

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

def get_english_etymology(word, key)
  url = "http://www.dictionaryapi.com/api/v1/references/collegiate/xml/#{word}?key=#{key}"
  uri = URI(url)
  response = Net::HTTP.get(uri)


  @etymologies = []
  xml_doc = Nokogiri::XML(response)
  # xml_doc.children.first.children[1].children[6]
  @etymology = xml_doc.search('//et')
  @etymology
end
