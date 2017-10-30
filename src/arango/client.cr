class Arango::Client
  getter :user
  setter :async
  Exception = ::Exception

  def self.from_config(yaml_file_path : String, 
                       identifier : String = "default",
                       env : String = "development")
    config = YAML.parse(File.read(yaml_file_path))
    config["arangodb"][env].each do |ident, db|
      if ident == identifier
        user = Arango::User.new(db["user"].as_s, db["password"].as_s)
        Database.client =  Arango::Client.new(db["endpoint"].as_s, user)
      end
    end
    Database.client
  end

  def initialize(@endpoint : String, @user : Arango::User)
    uri = URI.parse("#{@endpoint}")
    @http = HTTP::Client.new uri
    @async = false
    @user.authenticate @http
  end

  def database(database_name : String)
    Database.current = Database.new(database_name, self)
  end

  def get(url : String)
    response = @http.get(url, headers)
    result = JSON.parse(response.body)
    if result["error"] == true
      raise Exception.new "Http Api Error : #{result["code"]} #{result["errorMessage"]}"
    end
    result
  end

  def post(url : String, body : Hash | Array)
    response = @http.post(url, headers: headers, body: body.to_json)
    pp headers
    pp body.to_json
    result = JSON.parse(response.body)
    if result["error"] == true
      raise Exception.new "Http Api Error : #{result["code"]} #{result["errorMessage"]}"
    end
    result
  end

  def patch(url : String, body : Hash | Array)
    response = @http.patch(url, headers: headers, body: body.to_json)
    JSON.parse(response.body)
  end

  def delete(url : String)
    response = @http.delete(url, headers: headers)
    JSON.parse(response.body)
  end

  def delete(url : String, body : Hash)
    response = @http.delete(url, headers: headers, body: body.to_json)
    JSON.parse(response.body)
  end

  def put(url : String, body : Hash)
    response = @http.put(url, headers: headers, body: body.to_json)
    JSON.parse(response.body)
  end

  def head(url : String)
    response = @http.head(url, headers: headers)
    JSON.parse(response.body)
  end

  private def headers
    if @async
      HTTP::Headers{"Authorization" => "bearer #{@user.jwt}", "x-arango-async" => "true"}
    else
      HTTP::Headers{"Authorization" => "bearer #{@user.jwt}"}
    end
  end
end
