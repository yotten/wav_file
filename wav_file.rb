
class RiffHeader
  attr_reader(:riff, :size, :type)

  def initialize(wav_file)
    File.open(wav_file, "rb") do |f|
      @riff = f.read(4)
      @size = f.read(4).unpack("i").pop
      @type = f.read(4)
    end 
  end

  def print
    puts "riff=#{@riff}"
    puts "size=#{@size}"
    puts "type=#{@type}"
  end
end

class Chank
  attr_reader(:format_tag, :format_size, :desc)

  def initialize(f)
    @format_tag = f.read(4)
    @format_size = f.read(4).unpack("i").pop
    @desc = f
  end
end

class WavFormatPcm
  def initialize(f)
    @format_id = f.read(2).unpack("s").pop
    @channels = f.read(2).unpack("s").pop
    @sampling_rate = f.read(4).unpack("i").pop
    @byte_per_sec = f.read(4).unpack("i").pop
    @block_align = f.read(2).unpack("s").pop
    @bits_per_sample = f.read(2).unpack("s").pop
  end

  def print
    puts "format_id=#{@format_id}"
    puts "channels=#{@channels}"
    puts "ampling_rate=#{@sampling_rate}"
    puts "byte_per_sec=#{@byte_per_sec}"
    puts "block_align=#{@block_align}"
    puts "bits_per_sample=#{@bits_per_sample}"
  end
end

class WavFile
  def self.open(wav_file)
    File.open(wav_file, "rb") do |f|
      riff = f.read(4)
      return nil if riff != "RIFF"
    end

    return WavFile.new(wav_file)
  end

  def initialize(wav_file)
    @wav_file = wav_file
  end

  def read_all
    @riff_header = RiffHeader.new(@wav_file) 
    return if @riff_header.type != "WAVE"

    File.open(@wav_file) do |f|
      f.seek(12)
      chank = Chank.new(f)
      if chank.format_tag == "fmt "
        @wav_format = WavFormatPcm.new(chank.desc)  
      end
    end
  end

  def print_riff_header
    @riff_header.print
  end

  def print_wav_format
    @wav_format.print
  end
end 
