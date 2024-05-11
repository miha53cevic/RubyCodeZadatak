require 'net/http'

class AnswersController < ApplicationController
  def index
    render json: response_msg("image_url not supplied as parameter"), status: :bad_request
  end
  def image_url
    image_url = index_params

    if !valid_url?(image_url)
      return render json: response_msg("image_url format is incorrect"), status: :bad_request
    end

    render json: is_image?(image_url) ? response_msg("This is an image") : response_msg("This is not an image")
  end
  def api_docs
    render :api_docs
  end

  private
  def index_params
    parse_url(params[:image_url])
  end

  def parse_url(url)
    # Fix http:// being changed to http:/
    parsed_url = url
    if url.include?("https:/")
      parsed_url = url.sub("https:/", "https://")
    elsif url.include?("http:/")
      parsed_url = url.sub("http:/", "http://")
    end
    return parsed_url
  end

  def response_msg(msg)
    return { :message => msg }
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.kind_of?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    return false
  end

  def is_image?(url)
    # Try to get content type of url head fetch
    begin
      uri = URI.parse(url)
      content_type = ""
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        response = http.head(uri.path)
        content_type = response['Content-Type']
      end
      return content_type.include?("image/")
    rescue => e
      # Fallback check extension
      lastPathSegment = url.split('/')[-1]
      extension = lastPathSegment.include?(".") ? lastPathSegment.split(".")[-1] : nil

      if !extension.nil?
        return extension.downcase.in? ["jpg", "jpeg", "gif", "png", "webp"]
      end
      return false
    end
  end
end
