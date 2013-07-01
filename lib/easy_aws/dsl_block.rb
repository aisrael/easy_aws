module EasyAWS
  # Returns a block that acts as a facade for the given target, allowing
  # calls of the form
  #
  #    attribute 'value'
  #
  # and transforms them into the equivalent
  #
  #    @target.attribute = 'value'
  class DSLBlock
    attr_reader :target
    def initialize(target)
      @target = target
    end
    def method_missing(method_name, *args)
      setter = "#{method_name}=".to_sym
      if args && args.size == 1 && @target.respond_to?(setter)
        @target.send(setter, args.first)
      else
        super
      end
    end
    class << self
      def eval_using(target, block)
        DSLBlock.new(target).instance_eval(&block)
      end
    end
  end
end
