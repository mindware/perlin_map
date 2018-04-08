require 'oj'

module Base 
  class Obj 
    attr_accessor :name

    def initialize(name='ob')
      @name = name
    end

    def to_json
      Oj.dump(self, :indent => 2)  
    end

    class << self 
      def load_json(json)
        Oj.load(json, mode: :object)
      end
    end
  end
end 
