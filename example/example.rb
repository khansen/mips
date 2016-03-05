require 'mips/assembler'

Mips::Assembler.install_global_gpr_symbols
asm = Mips::Assembler.new
asm.instance_exec do
  org 0xfc000080
  addiu $t0, $zero, 100
  label :loop
  addiu $t0, $t0, -1
  bnez $t0, :loop
  nop
end

asm.save_instructions("code.bin")
