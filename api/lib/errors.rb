# frozen_string_literal: true

# general http errors allows for tracking the status code along with a message to be returned to the user
class HttpError < StandardError
  def initialize(statuscode, message)
    @statuscode = statuscode
    @message = message
    super "[#{@statuscode}] #{@message}"
  end
end

# HTTP status code 422 error
class ValidationError < HttpError
  def initialize(message)
    super(422, message)
  end
end

# HTTP status code 404 error
class NotFoundError < HttpError
  def initialize(message)
    super(404, message)
  end
end
