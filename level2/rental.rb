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


  # - Rental days multiplied by the car's price per day
  # - Kms multiplied by the car's price per km
  # 
  # - Price per day decreases by 10% after 1 day (only on days exceeding 1)
  # - Price per day decreases by 30% after 4 days (only on days exceeding 4)
  # - Price per day decreases by 50% after 10 days (only on days exceeding 10)
  def price
    duration_price + distance_price
  end

  private

  def duration_price
    duration_days = (Date.parse(@end_date) - Date.parse(@start_date)).to_i + 1

    duration_days * @car.price_per_day
  end

  def distance_price
    @distance * @car.price_per_km
  end
end