class Array
  def comb(n = size)
    if size < n or n < 0
    elsif n == 0
      yield([])
    else
      self[1..-1].comb(n) do |x|
	yield(x)
      end
      self[1..-1].comb(n - 1) do |x|
	yield([first] + x)
      end
    end
  end

  def to_h(default=nil)
    Hash[ *inject([]) { |a, value| a.push value, default || yield(value) } ]
  end
end
