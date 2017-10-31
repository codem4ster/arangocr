require "http/client"
require "json"
require "./nil_object"
require "./arango/**"

module Arango
  alias NillableDatabase = Database | NilObject
  alias NillableClient = Client | NilObject
end
