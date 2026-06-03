module ErrorHandler
  extend ActiveSupport::Concern

  # Custom exception for bad requests
  class BadRequest < StandardError; end

  included do
    rescue_from Mongoid::Errors::DocumentNotFound, with: :handle_not_found
    rescue_from Mongoid::Errors::Validations, with: :handle_validation_error
    rescue_from ErrorHandler::BadRequest, with: :handle_bad_request
  end

  private

  def handle_not_found(exception)
    render json: {
      error: "Resource not found",
      message: exception.message
    }, status: :not_found
  end

  def handle_validation_error(exception)
    render json: {
      error: "Validation failed",
      message: exception.message,
      errors: exception.document.errors.full_messages
    }, status: :unprocessable_entity
  end

  def handle_bad_request(exception)
    render json: {
      error: "Bad request",
      message: exception.message
    }, status: :bad_request
  end
end
