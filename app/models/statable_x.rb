
module StatableX
  @@metrics = {}
  
  def self.included(base)
    base.extend(self)
  end
  
  def metric(name, options = {})
    from = options[:from]

    unless from.nil?
      module_eval("def #{name}; Metric.#{name}.value(#{from.join(',')}); end")
    end
    module_eval("def #{name}_formatted; Metric.#{name}.value_formatted(#{(from || [name]).join(',')}); end")
    
    @@metrics[self] ||= []
    @@metrics[self] << Metric.get(name)

  end
  
  def metrics
    @@metrics[self]
  end
end
