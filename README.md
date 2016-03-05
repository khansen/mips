# MIPS Tools

## Synopsis

### Assembler

    require 'mips'

    asm = Mips::Assembler.new

    asm.instance_exec do
      org 0xfc000080
      addiu :$t0, :$zero, 100
      label :loop
      addiu :$t0, :$t0, -1
      bnez :$t0, :loop
      nop
    end

    asm.instructions.each { |instr| puts instr } # 32-bit word

    asm.save_instructions("foo.bin")

### Disassembler

    require 'mips'

    Mips::Disassembler.disassemble 604504164, { :vaddr => 0x3fc00000 }

## Development

### Tests

    rake test

### Gem

    rake gem

### Docs

    rake doc
