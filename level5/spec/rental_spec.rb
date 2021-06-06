require_relative '../rental'
require_relative '../car'
require_relative '../option'

describe Rental do
  let(:car_1) { Car.new(**{ id: 1, price_per_day: 2000, price_per_km: 10}) }

  let(:options) { [] }

  let(:rental_1) do
    Rental.new(car, options, **{ id: 1, car_id: 1, start_date: "2015-12-8", end_date: "2015-12-8", distance: 100 })
  end
  let(:rental_2) do
    Rental.new(car, options, **{ id: 1, car_id: 1, start_date: "2015-03-31", end_date: "2015-04-01", distance: 300 })
  end
  let(:rental_3) do
    Rental.new(car, options, **{ id: 1, car_id: 1, start_date: "2015-03-1", end_date: "2015-03-05", distance: 500 })
  end
  let(:rental_4) do
    Rental.new(car, options, **{ id: 1, car_id: 1, start_date: "2015-07-3", end_date: "2015-07-14", distance: 1000 })
  end

  describe '#price' do
    context 'with a car costing 20€ a day and 10 cents a km' do
      let(:car) { car_1 }

      context 'with a rental lasting 1 day and driving 100km' do
        let(:rental) { rental_1 }

        it 'costs 30€' do
          expect(rental.price).to eq(3000)
        end

        describe '[OPTIONS]' do
          context 'with a gps' do
            let(:options) { [Option.new(**{ id: 1, rental_id: 1, type: 'gps' })] }

            it 'costs 35€' do
              expect(rental.price).to eq(3500)
            end
          end

          context 'with a baby seat' do
            let(:options) { [Option.new(**{ id: 2, rental_id: 1, type: 'baby_seat' })] }

            it 'costs 32€' do
              expect(rental.price).to eq(3200)
            end
          end

          context 'with an additional insurance' do
            let(:options) { [Option.new(**{ id: 3, rental_id: 1, type: 'additional_insurance' })] }

            it 'costs 40€' do
              expect(rental.price).to eq(4000)
            end
          end
        end
      end

      context 'with a rental lasting 2 days and driving 300km' do
        let(:rental) { rental_2 }

        it 'costs 68€' do
          expect(rental.price).to eq(6800)
        end
      end

      context 'with a rental lasting 5 days and driving 500km' do
        let(:rental) { rental_3 }

        it 'costs 138€' do
          expect(rental.price).to eq(13800)
        end
      end

      context 'with a rental lasting 12 days and driving 1000km' do
        let(:rental) { rental_4 }

        it 'costs 278€' do
          expect(rental.price).to eq(27800)
        end
      end
    end
  end

  describe '#commission' do
    context 'with a car costing 20€ a day and 10 cents a km' do
      let(:car) { car_1 }

      context 'with a rental lasting 1 day and driving 100km' do
        let(:rental) { rental_1 }

        it 'returns commission details as expected' do
          expect(rental.commission).to eq({
            "insurance_fee": 450,
            "assistance_fee": 100,
            "drivy_fee": 350
          })
        end
      end

      context 'with a rental lasting 2 days and driving 300km' do
        let(:rental) { rental_2 }

        it 'returns commission details as expected' do
          expect(rental.commission).to eq({
            "insurance_fee": 1020,
            "assistance_fee": 200,
            "drivy_fee": 820
          })
        end
      end

      context 'with a rental lasting 12 days and driving 1000km' do
        let(:rental) { rental_4 }

        it 'returns commission details as expected' do
          expect(rental.commission).to eq({
            "insurance_fee": 4170,
            "assistance_fee": 1200,
            "drivy_fee": 2970
          })
        end
      end
    end
  end

  describe '#actions' do
    context 'with a car costing 20€ a day and 10 cents a km' do
      let(:car) { car_1 }

      context 'with a rental lasting 1 day and driving 100km' do
        let(:rental) { rental_1 }

        it 'returns action details as expected' do
          expect(rental.actions).to eq(
            [
              {
                "who": "driver",
                "type": "debit",
                "amount": 3000
              },
              {
                "who": "owner",
                "type": "credit",
                "amount": 2100
              },
              {
                "who": "insurance",
                "type": "credit",
                "amount": 450
              },
              {
                "who": "assistance",
                "type": "credit",
                "amount": 100
              },
              {
                "who": "drivy",
                "type": "credit",
                "amount": 350
              }
            ]
          )
        end

        describe '[OPTIONS]' do
          context 'with a gps and a baby seat' do
            let(:options) { [Option.new(**{ id: 1, rental_id: 1, type: 'gps' }),
                             Option.new(**{ id: 2, rental_id: 1, type: 'baby_seat' })] }

            it 'gives the extra money to the owner' do
              expect(rental.actions).to eq(
                [
                  {
                    "who": "driver",
                    "type": "debit",
                    "amount": 3700
                  },
                  {
                    "who": "owner",
                    "type": "credit",
                    "amount": 2800
                  },
                  {
                    "who": "insurance",
                    "type": "credit",
                    "amount": 450
                  },
                  {
                    "who": "assistance",
                    "type": "credit",
                    "amount": 100
                  },
                  {
                    "who": "drivy",
                    "type": "credit",
                    "amount": 350
                  }
                ]
              )
            end
          end

          context 'with an additional insurance' do
            let(:options) { [Option.new(**{ id: 3, rental_id: 1, type: 'additional_insurance' })] }

            it 'gives the extra money to drivy' do
              expect(rental.actions).to eq(
                [
                  {
                    "who": "driver",
                    "type": "debit",
                    "amount": 4000
                  },
                  {
                    "who": "owner",
                    "type": "credit",
                    "amount": 2100
                  },
                  {
                    "who": "insurance",
                    "type": "credit",
                    "amount": 450
                  },
                  {
                    "who": "assistance",
                    "type": "credit",
                    "amount": 100
                  },
                  {
                    "who": "drivy",
                    "type": "credit",
                    "amount": 1350
                  }
                ]
              )
            end
          end
        end
      end

      context 'with a rental lasting 2 days and driving 300km' do
        let(:rental) { rental_2 }

        it 'returns action details as expected' do
          expect(rental.actions).to eq(
            [
              {
                "who": "driver",
                "type": "debit",
                "amount": 6800
              },
              {
                "who": "owner",
                "type": "credit",
                "amount": 4760
              },
              {
                "who": "insurance",
                "type": "credit",
                "amount": 1020
              },
              {
                "who": "assistance",
                "type": "credit",
                "amount": 200
              },
              {
                "who": "drivy",
                "type": "credit",
                "amount": 820
              }
            ]
          )
        end
      end

      context 'with a rental lasting 12 days and driving 1000km' do
        let(:rental) { rental_4 }

        it 'returns action details as expected' do
          expect(rental.actions).to eq(
            [
              {
                "who": "driver",
                "type": "debit",
                "amount": 27800
              },
              {
                "who": "owner",
                "type": "credit",
                "amount": 19460
              },
              {
                "who": "insurance",
                "type": "credit",
                "amount": 4170
              },
              {
                "who": "assistance",
                "type": "credit",
                "amount": 1200
              },
              {
                "who": "drivy",
                "type": "credit",
                "amount": 2970
              }
            ]
          )
        end
      end
    end
  end
end