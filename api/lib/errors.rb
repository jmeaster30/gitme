# frozen_string_literal: true

module ErrorHelpers
  attr_accessor :statuscode, :message
end

class HttpError < StandardError
  include ErrorHelpers

  def initialize(statuscode, message)
    self.statuscode = statuscode
    self.message = message
  end
end

class ValidationError < HttpError
  include ErrorHelpers

  def initialize(message)
    super(422, message)
  end
end

class NotFoundError < HttpError
  include ErrorHelpers

  def initialize(message)
    super(404, message)
  end
end
