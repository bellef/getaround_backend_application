class Car
  def initialize(data)
    @id = data[:id]
    @price_per_day = data[:price_per_day]
    @price_per_km = data[:price_per_km]
  end
end
