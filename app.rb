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

  post "/" do
    message = params[:message]
    if message.length <= 140
      @database_connection.sql("INSERT INTO messages (message) VALUES ('#{message}')")
      redirect '/'
    else
      flash[:error] = "Message must be less than 140 characters."
      redirect '/'
    end
  end

  get "/:id/edit" do
    message = @database_connection.sql("SELECT * from messages where id = #{params[:id]}").first
    erb :edit, :locals => {:message => message}
  end

  patch "/:id/edit" do
    @database_connection.sql("UPDATE messages set message = '#{params[:message]}' where id = '#{params[:id]}'")
    redirect '/'
  end
  end
