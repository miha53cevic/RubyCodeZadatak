# frozen_string_literal: true

class AnswersController < ApplicationController
  def index
    render json: response_msg('image_url not supplied as parameter'), status: :bad_request
  end

  def image_url
    image_url = image_url_params
    return render json: response_msg('image_url format is incorrect'), status: :bad_request unless valid_url?(image_url)

    is_image = ImageChecker.new(image_url).call
    render json: is_image ? response_msg('This is an image') : response_msg('This is not an image')
  rescue StandardError => e
    render json: response_msg(e.message), status: :bad_request
  end

  def api_docs
    render :api_docs
  end

  private

  def image_url_params
    parse_url(params[:image_url])
  end

  def parse_url(url)
    # Fix http:// being changed to http:/
    parsed_url = url
    if url.include?('https:/')
      parsed_url = url.sub('https:/', 'https://')
    elsif url.include?('http:/')
      parsed_url = url.sub('http:/', 'http://')
    end
    parsed_url
  end

  def response_msg(msg)
    { message: msg }
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
