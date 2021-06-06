require 'JSON'
require 'Date'

class Rental
  def initialize(data, car)
    @id         = data[:id]
    @start_date = data[:start_date]
    @end_date   = data[:end_date]
    @distance   = data[:distance]
    @car        = car
  end

  def price
    duration_days = (Date.parse(@end_date) - Date.parse(@start_date)).to_i + 1

    duration_days * @car.price_per_day + @distance * @car.price_per_km
  end
end