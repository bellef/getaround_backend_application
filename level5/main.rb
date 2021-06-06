require_relative './rental'
require_relative './car'
require_relative './option'

INPUT_FILE_PATH  = 'data/input.json'
OUTPUT_FILE_PATH = 'data/output.json'

def deserialize_input_cars(input_data)
  input_data[:cars].map do |car_data|
    Car.new(**car_data)
  end
end

def deserialize_input_options(input_data)
  input_data[:options].map do |option_data|
    Option.new(**option_data)
  end
end

def deserialize_input_rentals(input_data, cars, available_options)
  input_data[:rentals].map do |rental_data|
    car     = cars.find { |car| car.id == rental_data[:car_id] }
    options = available_options.select { |option| option.rental_id == rental_data[:id] }

    Rental.new(car, options, **rental_data)
  end
end

def rentals_output(rentals)
  rentals.map do |rental|
    {
      id:      rental.id,
      options: rental.options.map(&:type),
      actions: rental.actions
    }
  end
end

def main
  input_data        = JSON.parse(File.read(INPUT_FILE_PATH), symbolize_names: true)
  cars              = deserialize_input_cars(input_data)
  available_options = deserialize_input_options(input_data)
  rentals           = deserialize_input_rentals(input_data, cars, available_options)
  output            = { rentals: rentals_output(rentals) }

  File.write(OUTPUT_FILE_PATH, JSON.generate(output))
end

main
