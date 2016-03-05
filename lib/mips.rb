# The Mips module contains utility classes for assembling and disassembling instructions.
#
# Mips::Assembler : An assembler.
#
# Mips::Disassembler : A disassembler.
module Mips
  autoload :Assembler, 'mips/assembler.rb'
  autoload :Disassembler, 'mips/disassembler.rb'
  autoload :PreparedInstruction, 'mips/prepared_instruction.rb'
end
