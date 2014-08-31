module Festoon
  class Dynamic
    def initialize(thing)
      @thing = thing
    end

    def method_missing(method_id, *args, &block)
      intercept_return_self(thing.public_send(method_id, *args, &block))
    end

    def __decompose__
      if thing.respond_to?(:__decompose__)
        [self, *thing.__decompose__]
      else
        [self, thing]
      end
    end

    def ==(other)
      if other.is_a?(self.class)
        other == thing
      else
        thing == other
      end
    end

    private

    def thing
      @thing
    end

    def intercept_return_self(value)
      value == thing ? self : value
    end

    def respond_to_missing?(method_id, *args)
      thing.respond_to?(method_id)
    end
  end
end
