module Insta

  class Client
    include HTTParty

    base_uri "https://instagram.com"

    def initialize

    end

    def get_user_pictures(count, token, user_id)
      self.class.get("/users/#{user_id}/media/recent", {
        query: {
          access_token: token,
          count: count,
        }
        })
    end
  end

end