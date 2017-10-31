module Arango::Query
  class Runner

    @query : String
    @database : Database | NilObject

    def initialize(@query, @database = Arango::Database.current)
      @query = @query.gsub("\n", " ")
    end

    def run(bind_vars = {} of String => String,
            count : Bool = false, 
            batch_size : Int32 = 500)
      body = { "query" => @query, "bindVars" => bind_vars, 
               "count" => count, "batchSize" => batch_size }
      response = @database.client.post("/_db/#{@database.name}/_api/cursor", body)
      response
    end
  end
end