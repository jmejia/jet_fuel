require 'sinatra'
require 'sinatra/activerecord'

ENV['DATABASE_URL'] ||= "sqlite3:///database.sqlite"

class Server < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :views, 'app/views'
  set :database, ENV['DATABASE_URL']
  set :session_secret, "shh_it_is_a_secret"
  enable :sessions

  before do
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  get "/" do
    erb :index
  end

  post "/login/?" do
    user = User.find_by_username(params[:username])
    if user
      salt = user.salt
      raw_pass = params[:password]
      salted_password = user.generate_salted_password(raw_pass)
      if user.salted_password == salted_password
        session[:user_id] = user.id
        redirect to("/users/#{user.username}")
      else
        body "Invalid Password"
      end
    else
      body "Invalid User"
    end
  end

  post "/shorten/?" do
    data = { original: params["url"],
           shortened: Url.random_string,
           count: 0,
           created_at: Time.now,
           updated_at: Time.now
         }
    if @current_user
      if PrivateUrl.find_by_original(params["url"])
        url = PrivateUrl.find_by_original(params["url"])
        redirect to("/users/#{@current_user.username}/urls/#{url.shortened}")
      else
        url = PrivateUrl.create(data)
        UserPrivateUrl.create({ user_id: @current_user.id,
                                private_url_id: url.id})
        redirect to("/users/#{@current_user.username}/urls/#{url.shortened}")
      end
    else
      if Url.find_by_original(params["url"])
        url = Url.find_by_original(params["url"])
        redirect to("/urls/#{url.shortened}")
      else
        url = Url.create(data)
        redirect to("/urls/#{url.shortened}")
      end
    end
  end

  get "/urls/?" do
    @popular_urls = Url.order(:count).all.reverse
    @recent_urls = Url.order(:created_at).all.reverse
    erb "urls/index".to_sym
  end

  get "/urls/:shortened/?" do
    @url = Url.find_by_shortened(params[:shortened])
    @short_link = "#{request.base_url}/#{@url.shortened}"
    erb "urls/show".to_sym
  end

  get '/users/new/?' do
    status 200
    erb "users/new".to_sym
  end

  get '/users/:username/urls/:shortened/?' do
    user = User.find_by_username(params[:username])
    if user && user.id == @current_user.id
      @url = PrivateUrl.find_by_shortened(params[:shortened])
      if @url
        @short_link = "#{request.base_url}/#{@url.shortened}"
        erb "urls/show".to_sym
      else
        redirect to("/")
      end
    else
      redirect to("/")
    end
  end

  post '/users/create/?' do
    if User.find_by_username(params[:username])
      body "User Already Exists..."
    else
      if params[:password] == params[:confirmation]
        salt = User.random_string
        raw_pass = params[:password]
        user = User.new({ username: params[:username], salt: salt})
        salted_password = user.generate_salted_password(raw_pass)
        User.create(username: user.username, salt: user.salt, salted_password: salted_password)
        redirect "/users/#{user.username}"
      else
        body "Passwords did not match..."
      end
    end
  end

  get '/users/:username/?' do
    @user = User.find_by_username(params[:username])
    if @user
      @private_urls = @user.private_urls.sort_by {|url| -url.count}
      erb "/users/show".to_sym
    else
      body "Invalid User"
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  get '/*' do
    requested_shortened_url = params[:splat].first

    url = Url.where(shortened: requested_shortened_url).first
    private_url = PrivateUrl.where(shortened: requested_shortened_url).first

    if url
      count = url.count + 1
      Url.update(url.id, :count => count)
      redirect to(url.original)
    elsif private_url
      count = private_url.count + 1
      PrivateUrl.update(private_url.id, :count => count)
      redirect to(private_url.original)
    else
      body "URL Not Found"
      redirect to("/urls")
    end
  end

end
