require_relative './rental'
require_relative './car'

INPUT_FILE_PATH  = 'data/input.json'
OUTPUT_FILE_PATH = 'data/output.json'

def deserialize_input_cars(input_data)
  input_data[:cars].map do |car_data|
    Car.new(car_data)
  end
end

def deserialize_input_rentals(input_data, cars)
  input_data[:rentals].map do |rental_data|
    car = cars.find { |car| car.id == rental_data[:car_id] }

    Rental.new(rental_data, car)
  end
end

def main
  input_data = JSON.parse(File.read(INPUT_FILE_PATH), symbolize_names: true)
  cars       = deserialize_input_cars(input_data)
  rentals    = deserialize_input_rentals(input_data, cars)

  puts cars
  puts rentals

  puts rentals.first.price
end

main
