# frozen_string_literal: true

class Option
  attr_reader :rental_id, :type

  def initialize(id:, rental_id:, type:)
    @id        = id
    @rental_id = rental_id
    @type      = type
  end
end