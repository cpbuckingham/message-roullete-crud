require "sinatra"
require "active_record"
require "gschool_database_connection"
require "rack-flash"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
  end

  get "/" do
    messages = @database_connection.sql("SELECT * FROM messages")

    erb :home, locals: {messages: messages}
  end

  get "/messages/:id/edit" do

    message = @database_connection.sql("SELECT * FROM messages WHERE id=#{params[:id]}").first

    erb :"messages/edit", locals: {message: message}
  end

  post "/messages" do
    message = params[:message]
    if message.length <= 140
      @database_connection.sql("INSERT INTO messages (message) VALUES ('#{message}')")
    else
      flash[:error] = "Message must be less than 140 characters."
    end
    redirect "/"
  end

  patch "/messages/:id" do
    message = params[:message]
    if message.length <= 140
      @database_connection.sql("UPDATE messages SET message = '#{params[:message]}' WHERE id = #{params[:id]}")
    else
      flash[:error] = "Message must be less than 140 characters."
      redirect "/messages/#{params[:id]}/edit"
    end
    redirect "/"
  end

  delete "/messages/:id" do
    @database_connection.sql("DELETE FROM messages WHERE id = #{params[:id]}")
    redirect "/"
  end

  get "/messages/:id/comment" do
    comments = @database_connection.sql("SELECT * from comments WHERE messages_id = #{params[:id]}")
    message = @database_connection.sql("SELECT * FROM messages WHERE id = #{params[:id]}").first
    erb :"messages/comment", locals: {comments: comments, message: message}
  end

  post "/messages/:id/comment" do
    @database_connection.sql("INSERT INTO comments (comment, messages_id) VALUES ('#{params[:comment]}', #{params[:id]})")
    redirect "/messages/#{params[:id]}/comment"
  end

  post "/messages/:id/likes" do
    @database_connection.sql("UPDATE messages SET likes = likes + 1 WHERE id=#{params[:id]}")
    redirect "/"
  end
  end

