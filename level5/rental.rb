# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'JSON'
require 'Date'

class Rental
  attr_reader :id, :options

  def initialize(params)
    @car        = params[:car]
    @options    = params[:options] || []
    @car_id     = params[:car_id]
    @id         = params[:id]
    @start_date = params[:start_date]
    @end_date   = params[:end_date]
    @distance   = params[:distance]
  end

  def price
    (duration_price + distance_price + options_price).to_i
  end

  # - 30% commission on rental price /!\ Without options /!\
  # - half goes to the insurance
  # - 1€/day goes to the roadside assistance
  # - the rest goes to us
  BASE_COMMISSION_RATE = 0.3
  def commission
    base_commission = (price - options_price) * BASE_COMMISSION_RATE

    insurance_fee  = base_commission / 2
    assistance_fee = duration_days * 100
    drivy_fee      = base_commission - (insurance_fee + assistance_fee)

    {
      insurance_fee: insurance_fee.to_i,
      assistance_fee: assistance_fee.to_i,
      drivy_fee: drivy_fee.to_i
    }
  end

  OPTIONS_PRICING_RULES = {
    gps: { price_per_day: 500,  beneficiary: 'owner' },
    baby_seat: { price_per_day: 200, beneficiary: 'owner' },
    additional_insurance: { price_per_day: 1000, beneficiary: 'drivy' }
  }.freeze
  def actions
    rental_commission_details = commission
    rental_fees_total         = rental_commission_details.inject(0) do |c, (_k, v)|
      c + v
    end
    owner_credit = price - rental_fees_total -
                   options_price + options_price(beneficiary: 'owner')

    [
      {
        "who":    'driver',
        "type":   'debit',
        "amount": price
      },
      {
        "who":    'owner',
        "type":   'credit',
        "amount": owner_credit
      },
      {
        "who":    'insurance',
        "type":   'credit',
        "amount": rental_commission_details[:insurance_fee]
      },
      {
        "who":    'assistance',
        "type":   'credit',
        "amount": rental_commission_details[:assistance_fee]
      },
      {
        "who":    'drivy',
        "type":   'credit',
        "amount": rental_commission_details[:drivy_fee] + options_price(beneficiary: 'drivy')
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
  ].freeze
  def duration_price
    duration = duration_days
    price = 0

    DECREASING_PRICING_RULES.each do |rule|
      next unless duration > rule[:threshold_days]

      price += (duration - rule[:threshold_days]) *
               ((1 - rule[:daily_price_reduction]) * @car.price_per_day)
      duration = rule[:threshold_days]
    end

    # No price reduction for the remaining duration
    price += duration * @car.price_per_day

    price
  end

  def distance_price
    @distance * @car.price_per_km
  end

  # If given no parameter, #options_price returns the total price for all options
  # If given a beneficiary, it returns the total price
  #   only benefiting to the given beneficiary
  def options_price(beneficiary: '.*')
    @options.inject(0) do |c, option|
      current_option_rules = OPTIONS_PRICING_RULES[option.type.to_sym]

      if current_option_rules[:beneficiary].match?(beneficiary)
        price_per_day = current_option_rules[:price_per_day]

        c + price_per_day * duration_days
      else
        c
      end
    end
  end
end
