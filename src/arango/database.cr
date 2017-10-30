require "./client"
require "yaml"

class Arango::Database
  class_property :current, :client
  class_getter :instances
  getter :client

  @@client : NillableClient = NilObject.new("Client")
  @@instances = {} of String => Arango::Database
  @@current : NillableDatabase = NilObject.new("Database")

  def self.user : Arango::User
    @@client.user 
  end

  def self.create(db_name : String, user_list = [user])
    user_arr = user_list.map { |u| { "username" => u.username } }
    body = {"name" => db_name, "users" => user_arr}
    if @@client.post("/_api/database", body)["result"] == true
      new_db = new(db_name)
      return new_db unless @@current.is_a?(NilObject)
      @@current = new_db 
    end
  end

  # Creates and return database if it doesn't exists on client
  #   returns the database only if it exists on client
  def self.grab(db_name : String)
    if all.includes? db_name
      @@client.database db_name
    else
      create db_name
    end
  end

  def self.all
    @@client.get("/_api/database")["result"]
  end

  def self.switch(identifier : String)
    raise "Unknown database identifier : #{identifier}" unless @@instances.has_key?(identifier)
    @@current = @@instances[identifier]
  end

  def self.from_config(yaml_file_path : String, 
                       identifier : String | Nil = nil,
                       env : String = "development")
    config = YAML.parse(File.read(yaml_file_path))
    config["arangodb"][env].each do |ident, db| 
      user = Arango::User.new(db["user"].as_s, db["password"].as_s)
      client = Arango::Client.new(db["endpoint"].as_s, user)
      self.client = client
      self.new(db["name"].as_s, client, ident.as_s)
    end
    return @@current = self.instances[identifier] unless identifier.nil?
    self.instances
  end

  def self.delete(name : String)
    @@client.delete("/_api/database/#{name}")
  end

  def initialize(@database : String, 
                 @client : NillableClient = @@client, 
                 identifier : String | Nil = nil) 
    @@instances[identifier] = self unless identifier.nil?
    @@current = self if @@current.nil? || identifier == "default"
  end 
  
  def name
    @database
  end

  def [](name)
    collection(name)
  end

  def collection(name)
    Collection.new(@client, @database, name)
  end

  def aql
    Aql.new(@client, @database)
  end
end
