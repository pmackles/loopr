require 'RMagick'


class IconMaker
  attr_accessor :data_file, :path

  def initialize(data_file)
    @data_file = data_file
  end
  
  def save_to_file(path)
    if data_file.nil? || data_file.size == 0 || data_file.size > 2048*1024
      return false
    end
 
    begin
      images = Magick::Image.from_blob(data_file.read)
    rescue Magick::ImageMagickError
      return false
    end
    
    if images.empty?  
      return false
    end
    
    img = images[0]
    width = img.columns
    height = img.rows
    if width != 96 || height != 96
      img.thumbnail!(96, 96)
    end

    img.write(UPLOAD_DIR + path)
  end
  
end
