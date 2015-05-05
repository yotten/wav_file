# -*- coding: utf-8 -*-
require './wav_file.rb'

if ARGV[0] == nil
  puts "Usage: ruby wav_program.rb wav_file"
  exit
end

wav_file = ARGV[0]
wav = WavFile.open(wav_file)
if wav == nil
  puts "not RIFF"
  exit
end

begin
  wav.read_all
rescue
  puts "not WAVE" 
end

wav.print_riff_header
wav.print_wav_format
