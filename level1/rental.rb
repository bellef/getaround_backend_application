require 'JSON'
require 'Date'

class Rental
  attr_reader :id

  def initialize(car, car_id:, id:, start_date:, end_date:, distance:)
    @car        = car
    @car_id     = car_id
    @id         = id
    @start_date = start_date
    @end_date   = end_date
    @distance   = distance
  end

  def price
    duration_days = (Date.parse(@end_date) - Date.parse(@start_date)).to_i + 1

    duration_days * @car.price_per_day + @distance * @car.price_per_km
  end
end