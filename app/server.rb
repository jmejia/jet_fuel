require 'sinatra'
require 'sinatra/activerecord'

ENV['DATABASE_URL'] ||= "sqlite3:///database.sqlite"

class Server < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :views, 'app/views'
  set :database, ENV['DATABASE_URL']

  get "/" do
    erb :index
  end

  get "/login/?" do
    status 200
    erb "sessions/new".to_sym
  end

  post "/shorten/?" do
    data = { original: params["url"],
             shortened: Url.random_string,
             count: 0,
             created_at: Time.now,
             updated_at: Time.now
           }
    if Url.find_by_original(params["url"])
      url = Url.find_by_original(params["url"])
      redirect to("/urls/#{url.shortened}")
    else
      url = Url.create(data)
      redirect to("/urls/#{url.shortened}")
    end
  end

  get "/urls/?" do
    @popular_urls = Url.order(:count).all.reverse
    @recent_urls = Url.order(:created_at).all
    erb "urls/index".to_sym
  end

  get "/urls/:shortened/?" do
    @url = Url.find_by_shortened(params[:shortened])
    @short_link = "#{request.base_url}/#{@url.shortened}"
    erb "urls/show".to_sym
  end

  get '/*' do
    requested_shortened_url = params[:splat].first

    url = Url.where(shortened: requested_shortened_url).first

    if url
      count = url.count + 1
      Url.update(url.id, :count => count)
      redirect to(url.original)
    else
      body "URL Not Found"
      redirect to("/urls")
    end
  end

end
