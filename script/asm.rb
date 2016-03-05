require 'mips/assembler'

asm = Mips::Assembler.new
filename = ARGV.first
asm.instance_eval File.read(filename), filename

asm.save_instructions("asm.out")
