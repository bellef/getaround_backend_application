# frozen_string_literal: true

class Option
  attr_reader :rental_id, :type

  def initialize(params)
    @id        = params[:id]
    @rental_id = params[:rental_id]
    @type      = params[:type]
  end
end