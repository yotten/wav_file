# -*- coding: utf-8 -*-

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
    puts "--- RiffHeader ---" 
    puts "riff=#{@riff}"
    puts "size=#{@size}"
    puts "type=#{@type}"
    puts "---"
  end
end

class Chank
  attr_reader(:format_tag, :format_size, :desc)

  def initialize(f)
    @format_tag = f.read(4)
    @format_size = f.read(4).unpack("i").pop
#    puts "format_size=#{@format_size}"
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
    puts "--- WavFormatPcm ---"
    puts "format_id=#{@format_id}" + wave_format
    #wave_format 
    puts "channels=#{@channels}"
    puts "ampling_rate=#{@sampling_rate}"
    puts "byte_per_sec=#{@byte_per_sec}"
    puts "block_align=#{@block_align}"
    puts "bits_per_sample=#{@bits_per_sample}"
    puts "---"
  end

private
  def wave_format
    case @format_id
    when 0x0000
      "(WAVE_FORMAT_UNKNOWN)"
    when 0x0001
      "(WAVE_FORMAT_PCM)"
    else
      "???" 
    end 
  end
end

class DataFormat
  def initialize(f, size)
    @desc = f
    @size = size
    puts "pos=#{f.tell}"
    puts "size=#{size}" 
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
    raise if @riff_header.type != "WAVE" 

    File.open(@wav_file) do |f|
      f.seek(12)
      while chank = Chank.new(f) do
        if chank.format_tag == "fmt "
          @wav_format = WavFormatPcm.new(chank.desc)
        elsif chank.format_tag == "data"
          @data_format = DataFormat.new(chank.desc, chank.format_size) 
          puts "data!!!!!"
        else
          puts "!!!!!!!!"
          break
        end
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
