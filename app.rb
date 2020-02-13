require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db 
  @db = SQLite3::Database.new 'heytheresinatra.db'
  @db.results_as_hash = true
end

before do 
  init_db
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

get '/' do
  erb 'Hello World!'
end

get '/new' do
  erb :new
end

post '/new' do
  content = params[:content]

  erb content
end