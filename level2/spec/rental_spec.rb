require_relative '../rental'
require_relative '../car'

describe Rental do
  describe '#price' do
    context 'with a car costing 20€ a day and 10 cents a km' do
      let(:car) { Car.new(**{ id: 1, price_per_day: 2000, price_per_km: 10}) }

      context 'with a rental lasting 1 day and driving 100km' do
        let(:rental) do
          Rental.new(car, **{ id: 1, car_id: 1, start_date: "2015-12-8", end_date: "2015-12-8", distance: 100 })
        end

        it 'costs 30€' do
          expect(rental.price).to eq(3000)
        end
      end

      context 'with a rental lasting 2 days and driving 300km' do
        let(:rental) do
          Rental.new(car, **{ id: 1, car_id: 1, start_date: "2015-03-31", end_date: "2015-04-01", distance: 300 })
        end

        it 'costs 68€' do
          expect(rental.price).to eq(6800)
        end
      end

      context 'with a rental lasting 5 days and driving 500km' do
        let(:rental) do
          Rental.new(car, **{ id: 1, car_id: 1, start_date: "2015-03-1", end_date: "2015-03-05", distance: 500 })
        end

        it 'costs 138€' do
          expect(rental.price).to eq(13800)
        end
      end

      context 'with a rental lasting 12 days and driving 1000km' do
        let(:rental) do
          Rental.new(car, **{ id: 1, car_id: 1, start_date: "2015-07-3", end_date: "2015-07-14", distance: 1000 })
        end

        it 'costs 278€' do
          expect(rental.price).to eq(27800)
        end
      end
    end
  end
end