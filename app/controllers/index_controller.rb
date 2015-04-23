require "sinatra"
require "instagram"
require "dotenv"
require "httparty"

Dotenv.load
enable :sessions

# redirect url after oath
CALLBACK_URL = "http://localhost:9393/oauth/callback"

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

# FOR REFERENCE:
# image location:
# client.user_recent_media[#]

# .location returns:
# {"latitude"=>37.781923821, "longitude"=>-122.408287622}

# .tags returns hashtags

# .type returns "image" or video

# .images gives this hash:
 #  {"low_resolution"=>
 #  {"url"=>
 #    "https://scontent.cdninstagram.com/hphotos-xaf1/t51.2885-15/s306x306/e15/11142246_666301880162726_1798201019_n.jpg",
 #   "width"=>306,
 #   "height"=>306},
 # "thumbnail"=>
 #  {"url"=>
 #    "https://scontent.cdninstagram.com/hphotos-xaf1/t51.2885-15/s150x150/e15/11142246_666301880162726_1798201019_n.jpg",
 #   "width"=>150,
 #   "height"=>150},
 # "standard_resolution"=>
 #  {"url"=>
 #    "https://scontent.cdninstagram.com/hphotos-xaf1/t51.2885-15/e15/11142246_666301880162726_1798201019_n.jpg",
 #   "width"=>640,
 #   "height"=>640}}


# return array with all the images in user media
get "/users/self/feed" do

  client = Instagram.client(access_token: session[:access_token])
  user = client.user
  # api = Insta::Client.new
  # media = JSON.parse(api.get_user_pictures(user.counts.media, session[:access_token], user.id))

  media = client.user_recent_media(user.id, {count: user.counts.media})
  image_container = []
  media.each do |image|
    if image["location"]
      if image["location"]["latitude"]
      image_container << {
        url: image.images.standard_resolution.url,
        thumbnail: image.images.thumbnail.url,
        location: image.location,
        }
      end
    end
  end
  return image_container.to_json
end

# return array with first two pages of news feed
get "/user_media_feed" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user

  page_1 = client.user_media_feed(user.counts.media)

  page_2_max_id = page_1.pagination.next_max_id
  page_2 = client.user_media_feed( :max_id => page_2_max_id ) unless page_2_max_id.nil?

  image_container = []

  page_1.each do |image|
    if image["location"]
      if image["location"]["latitude"]
      image_container << {
        url: image.images.standard_resolution.url,
        thumbnail: image.images.thumbnail.url,
        location: image.location,
        }
      end
    end
  end
  page_2.each do |image|
    if image["location"]
      if image["location"]["latitude"]
      image_container << {
        url: image.images.standard_resolution.url,
        thumbnail: image.images.thumbnail.url,
        location: image.location,
        }
      end
    end
  end
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

get "/sessions/logout" do
  session["access_token"] = nil
  session["session_id"] = nil
  redirect "/"
end
