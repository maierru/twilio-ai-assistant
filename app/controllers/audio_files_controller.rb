class AudioFilesController < ApplicationController
  def show
    filename = params[:filename]
    filename += '.mp3' unless filename.end_with?('.mp3')
    file_path = Rails.root.join('storage', 'tts', filename)
    
    if File.exist?(file_path)
      send_file file_path, type: 'audio/mpeg', disposition: 'inline'
    else
      Rails.logger.error "Audio file not found: #{file_path}"
      head :not_found
    end
  end
end
