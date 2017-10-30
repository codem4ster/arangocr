require "./client"

class Arango::Collection
  @@name : String = ""

  def self.database
    Arango::Database.current
  end

  def self.client
    Arango::Database.client
  end

  def self.create(collection_name : String, properties = {} of String => String)
    body = {"name" => collection_name}
    body.merge! properties
    client.post("/_db/#{database.name}/_api/collection", body)
    new collection_name
  end

  def self.all
    client.get("/_db/#{database.name}/_api/collection")["result"]
  end

  # Creates and return collection if it doesn't exists on database
  #   returns the collection only if it exists on database
  def self.grab(collection_name : String)
    if all.includes? collection_name
      new collection_name
    else
      create collection_name
    end
  end

  def initialize(@name : String = @@name, @database : NillableDatabase = self.class.database); end

  def client
    @database.client
  end  

  def delete
    client.delete("/_db/#{@database.name}/_api/collection/#{@name}")
  end

  def truncate
    client.put("/_db/#{@database.name}/_api/collection/#{@name}/truncate", {} of String => String)
  end

  def infos
    client.get("/_db/#{@database.name}/_api/collection/#{@name}")
  end

  def properties
    client.get("/_db/#{@database.name}/_api/collection/#{@name}/properties")
  end

  def count
    client.get("/_db/#{@database.name}/_api/collection/#{@name}/count")
  end

  def figures
    client.get("/_db/#{@database.name}/_api/collection/#{@name}/figures")
  end

  def revision
    client.get("/_db/#{@database.name}/_api/collection/#{@name}/revision")
  end

  def checksum
    client.get("/_db/#{@database.name}/_api/collection/#{@name}/checksum")
  end

  def all
    client.get("/_db/#{@database.name}/_api/collection")
  end

  def all_keys(_type = "path")
    client.put("/_db/#{@database.name}/_api/simple/all-keys", {"collection" => @name, "type" => _type})
  end

  def load
    client.put("/_db/#{@database.name}/_api/collection/#{@name}/load", {} of String => String)
  end

  def unload
    client.put("/_db/#{@database.name}/_api/collection/#{@name}/unload", {} of String => String)
  end

  def update_properties(body : Hash)
    client.put("/_db/#{@database.name}/_api/collection/#{@name}/unload", body)
  end

  def rename(new_name : String)
    client.put("/_db/#{@database.name}/_api/collection/#{@name}/rename", {"name" => new_name})
  end

  def rotate
    client.put("/_db/#{@database.name}/_api/collection/#{@name}/rotate", {} of String => String)
  end

  def document
    Document.new(client, @database.name, @name)
  end
end
