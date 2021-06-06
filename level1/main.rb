require_relative './rental'
require_relative './car'

INPUT_FILE_PATH  = 'data/input.json'
OUTPUT_FILE_PATH = 'data/output.json'

def deserialize_input_cars(input_data)
  input_data['cars'].map do |car|
    Car.new(car)
  end
end

def deserialize_input_rentals(input_data)
  input_data['rentals'].map do |rental|
    Rental.new(rental)
  end
end

def main
  input_data = JSON.parse(File.read(INPUT_FILE_PATH))
  cars       = deserialize_input_cars(input_data)
  rentals    = deserialize_input_rentals(input_data)

  puts cars
  puts rentals
end

main
