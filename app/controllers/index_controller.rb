require "sinatra"
require "instagram"
# require "dotenv"
require "httparty"
require "pp"

# Dotenv.load
enable :sessions

# redirect url after oath
CALLBACK_URL = "http://mapup.herokuapp.com/oauth/callback"

Instagram.configure do |config|
  config.client_id = ENV['CLIENT_ID']
  config.client_secret = ENV['CLIENT_SECRET']
end

# redirect to instagram oath
get "/" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

# have href to this if decide to have homepage
## on authorize send callback url
# get "/oauth/connect" do
#   redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
# end

# save access token in sessions and redirect to index
get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/index"
end

# index page
get "/index" do
  client = Instagram.client(access_token: session[:access_token])
  @user = client.user

  # create user if new user, reset profile pic and pic counter either way
  if !User.where(username: @user.username).first
    new_user = User.create(
      username: @user.username,
      profile_pic: @user.profile_picture,
      pic_count: @user.counts.media,
      )
  else
    user = User.where(username: @user.username).first
    user.profile_pic = @user.profile_picture
    user.pic_count =  @user.counts.media
    user.save
  end
  erb :index
end


# return array with all the images in user media
get "/users/self/feed" do

  client = Instagram.client(access_token: session[:access_token])
  user = client.user

  image_container = []
  count = 0
  next_max_id = nil
  while count < user.counts.media do
    if next_max_id != nil
      current_page = client.user_recent_media(user.id, {count: 33, max_id: next_max_id})
    else
      current_page = client.user_recent_media(user.id, {count: 33})
    end
    next_max_id = current_page.pagination.next_max_id
    current_page.each do |image|
      if image["location"]
        if image["location"]["latitude"]
        image_container << {
          url: image.images.standard_resolution.url,
          thumbnail: image.images.thumbnail.url,
          location: image.location,
          tags: image.tags,
          username: image.user.username,
          }
        end
      end
    end
    count += current_page.count
  end
  return image_container.to_json
end

# return array with first 100 geotagged images of news feed
get "/user_media_feed" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user
  image_container = []

  count = 0
  next_max_id = nil
  while image_container.count < 100 do
    if next_max_id != nil
      current_page = client.user_media_feed({count: 33, max_id: next_max_id})
    else
      current_page = client.user_media_feed({count: 33})
    end
    next_max_id = current_page.pagination.next_max_id
    current_page.each do |image|
      puts image
      if image["location"]
        if image["location"]["latitude"]
        image_container << {
          url: image.images.standard_resolution.url,
          thumbnail: image.images.thumbnail.url,
          location: image.location,
          tags: image.tags,
          username: image.user.username,
          }
        end
      end
    end
    count += current_page.count
    p count
  end
  p image_container.count
  return image_container.to_json
end

# REFERENCE:
# get "/user_search" do
#   client = Instagram.client(:access_token => session[:access_token])
#   html = "<h1>Search for users on instagram, by name or usernames</h1>"
#   for user in client.user_search("instagram")
#     html << "<li> <img src='#{user.profile_picture}'> #{user.username} #{user.full_name}</li>"
#   end
#   html
# end

# get "/location_search" do
#   client = Instagram.client(:access_token => session[:access_token])
#   html = "<h1>Search for a location by lat/lng with a radius of 5000m</h1>"
#   for location in client.location_search("48.858844","2.294351","5000")
#     html << "<li> #{location.name} <a href='https://www.google.com/maps/preview/@#{location.latitude},#{location.longitude},19z'>Map</a></li>"
#   end
#   html
# end

# get "/sessions/logout" do
#   session["access_token"] = nil
#   session["session_id"] = nil
#   redirect "/"
# end

get '/media_like/:id' do
  client = Instagram.client(:access_token => session[:access_token])
  client.like_media("#{params[:id]}")
end

get '/media_unlike/:id' do
  client = Instagram.client(:access_token => session[:access_token])
  client.unlike_media("#{params[:id]}")
end
