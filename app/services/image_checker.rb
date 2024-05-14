# frozen_string_literal: true

class ImageChecker
  def initialize(image_url)
    @image_url = image_url
  end

  def call
    raise 'image_url is missing or empty' if @image_url.nil? || @image_url.empty?

    image?
  end

  private

  def image?
    last_path_segment = @image_url.split('/').last
    return false if last_path_segment.nil?

    extension = last_path_segment.include?('.') ? last_path_segment.split('.').last : ''
    %w[jpg jpeg gif png webp].include?(extension.downcase)
  end
end
