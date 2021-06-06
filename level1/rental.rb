require 'JSON'
require 'Date'

class Rental
  def initialize(data)
    @id         = data[:id]
    @car_id     = data[:car_id]
    @start_date = data[:start_date]
    @end_date   = data[:end_date]
    @distance   = data[:distance]
  end

  def price
    # TODO
  end
end