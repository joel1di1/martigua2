# frozen_string_literal: true

class FfhbServiceError < StandardError
  # HTTP status of the FFHB response when the error comes from one, nil otherwise.
  attr_reader :status

  def initialize(message = nil, status: nil)
    super(message)
    @status = status
  end

  def server_error?
    status.to_i >= 500
  end
end
