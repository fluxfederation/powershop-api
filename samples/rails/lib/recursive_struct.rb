class RecursiveStruct
  instance_methods.each {|m| undef_method m unless m =~ /(^__|^send$|^object_id$)/}
  
  def initialize(hash)
    @hash = hash
  end
  
  def method_missing(method, *args)
    if @hash.respond_to?(method)
      @hash.send(method, *args)
    elsif @hash.member?(method.to_s)
      value = @hash[method.to_s]
      case value
      when Hash then RecursiveStruct.new(value)
      when Array then value.collect {|a| a.is_a?(Hash) ? RecursiveStruct.new(a) : a}
      else value
      end
    else
      super
    end
  end
end
