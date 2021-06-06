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
    (duration_price + distance_price).to_i
  end

  # - 30% commission on rental price
  # - half goes to the insurance
  # - 1€/day goes to the roadside assistance
  # - the rest goes to us
  BASE_COMMISSION_RATE = 0.3
  def commission
    base_commission = price * BASE_COMMISSION_RATE

    insurance_fee  = base_commission / 2
    assistance_fee = duration_days * 100
    drivy_fee      = base_commission - (insurance_fee + assistance_fee)

    {
      insurance_fee: insurance_fee.to_i,
      assistance_fee: assistance_fee.to_i,
      drivy_fee: drivy_fee.to_i
    }
  end

  def actions
    rental_price              = price
    rental_commission_details = commission
    rental_fees_sum           = rental_commission_details.inject(0) do |c, (_k, v)|
                                  c + v
                                end
    owner_credit              = rental_price - rental_fees_sum

    [
      {
        "who": "driver",
        "type": "debit",
        "amount": rental_price
      },
      {
        "who": "owner",
        "type": "credit",
        "amount": owner_credit
      },
      {
        "who": "insurance",
        "type": "credit",
        "amount": rental_commission_details[:insurance_fee]
      },
      {
        "who": "assistance",
        "type": "credit",
        "amount": rental_commission_details[:assistance_fee]
      },
      {
        "who": "drivy",
        "type": "credit",
        "amount": rental_commission_details[:drivy_fee]
      }
    ]
  end

  private

  def duration_days
    (Date.parse(@end_date) - Date.parse(@start_date)).to_i + 1
  end

  DECREASING_PRICING_RULES = [
    {
      threshold_days: 10,
      daily_price_reduction: 0.5
    },
    {
      threshold_days: 4,
      daily_price_reduction: 0.3
    },
    {
      threshold_days: 1,
      daily_price_reduction: 0.1
    }
  ]
  def duration_price
    duration = duration_days
    price = 0

    DECREASING_PRICING_RULES.each do |rule|
      if duration > rule[:threshold_days]
        price += (duration - rule[:threshold_days]) *
                 ((1 - rule[:daily_price_reduction]) * @car.price_per_day)
        duration = rule[:threshold_days]
      end
    end

    # No price reduction for the remaining duration
    price += duration * @car.price_per_day

    price
  end

  def distance_price
    @distance * @car.price_per_km
  end
end