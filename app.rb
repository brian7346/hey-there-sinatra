require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db 
  @db = SQLite3::Database.new 'heytheresinatra.db'
  @db.results_as_hash = true
end

def init_table 
  @db.execute 'CREATE TABLE IF NOT EXISTS "Posts" (
    "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
    "created_date"	DATE,
    "content"	TEXT
  );'
end

before do 
  init_db
end

configure do
  init_db
  init_table
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

get '/' do
  @results = @db.execute 'select * from Posts order by id desc'

  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  content = params[:content].strip

  if content.length == 0
    @error = "Type post text"

    return erb :new
  end

  @db.execute 'insert into Posts (content, created_date) values(?, datetime())', [content]

  redirect to '/'
end