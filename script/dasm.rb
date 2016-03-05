require 'mips/disassembler'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: dasm.rb [options] FILE"

  opts.on("--offset OFFSET", OptionParser::OctalInteger, "File offset") do |offset|
    options[:file_offset] = offset
  end
  opts.on("--origin ORIGIN", OptionParser::OctalInteger, "Origin address") do |origin|
    options[:origin_address] = origin
  end
  opts.on("--count COUNT", OptionParser::OctalInteger, "Max instruction count") do |count|
    options[:instruction_count] = count
  end
end.parse!

File.open(ARGV[0]) do |file|
  if options.include?(:file_offset)
    file.seek(options[:file_offset].to_i)
  end
  virt_addr_base = options[:origin_address] || 0
  count = options[:instruction_count]
  index = 0
  while (count.nil? || index < count) && (buf = file.read(4))
    inst_word = buf.unpack("L>").first
    puts Mips::Disassembler.disassemble(inst_word, :vaddr => virt_addr_base + index*4) unless inst_word.nil?
    index += 1
  end
end
