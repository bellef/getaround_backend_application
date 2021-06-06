require_relative '../rental'
require_relative '../car'

describe Rental do
  describe '#price' do
    context 'with a car costing 20€ a day and 10 cents a km' do
      let(:car) { Car.new(**{ id: 1, price_per_day: 2000, price_per_km: 10}) }

      context 'with a rental lasting 3 days and driving 100km' do
        let(:rental) do
          Rental.new(car, **{ id: 1, car_id: 1, start_date: "2017-12-8", end_date: "2017-12-10", distance: 100 })
        end

        it 'costs 70€' do
          expect(rental.price).to eq(7000)
        end
      end
    end
  end
end