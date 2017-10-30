class NilObject
  
    macro method_missing(method_name)
      raise "#{@name} is missing"
    end
  
    def initialize(@name : String); end
  end