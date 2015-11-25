require "sinatra"
require "pg"
require 'pry'

configure :development do
  set :db_config, { dbname: "grocery_list_development" }
end

configure :test do
  set :db_config, { dbname: "grocery_list_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

def all_groceries
  db_connection do |conn|
    sql_query = "SELECT * FROM groceries"
    conn.exec(sql_query)
  end
end

def add_grocery(params)
  unless params["name"].empty?
    db_connection do |conn|
      sql_query = "INSERT INTO groceries(name) VALUES ($1)"
      data = [params["name"]]
      conn.exec_params(sql_query,data)
    end
  end
end

def item_find(id)
  db_connection do |conn|
    sql_query = "SELECT * FROM groceries WHERE groceries.id = ($1)"
    data = [id]
    conn.exec_params(sql_query,data)
  end
end

def item_comments(id)
  db_connection do |conn|
    sql_query = "SELECT groceries.*, comments.* FROM groceries JOIN comments ON comments.grocery_id = groceries.id WHERE groceries.id = $1"
    data = [id]
    conn.exec_params(sql_query,data)
  end
end

get "/" do
  redirect "/groceries"
end

get "/groceries" do
  @groceries = all_groceries
  erb :groceries
end

post "/groceries" do
  add_grocery(params)
  redirect "/groceries"
end

get "/groceries/:id" do
  @grocery_item = item_find(params[:id])
  @comments = item_comments(params[:id])
  erb :grocery_item
end
