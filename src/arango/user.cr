class Arango::User
  property :username
  property :password
  getter :jwt

  def initialize(@username : String, @password : String)
  end

  # Authenticates the user
  def authenticate(http_client : HTTP::Client)
    response = http_client.post_form("/_open/auth", {"username" => username, "password" => password}.to_json)
    if response.status_code == 200
      @jwt = JSON.parse(response.body)["jwt"].to_s.as(String)
    elsif response.status_code == 404
      raise "Warning! It looks like you are using a passwordless configuration!"
    else
      raise "Error #{response.status_code} #{response.status_message}"
    end
  end
end