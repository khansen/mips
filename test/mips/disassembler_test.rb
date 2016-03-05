require 'test/unit'
require 'mips'

module Mips
class DisassemblerTest < Test::Unit::TestCase #:nodoc:
  def setup
    @_ = Assembler.new
  end

  def test_j
    @_.j 0x7000
    puts Disassembler.disassemble(@_.instructions.last, :vaddr => 0xffffffff80000180)
  end

  def test_add3
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x20)
    assert_equal :add, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_addi
    rt = 10; rs = 20; imm = 30
    decoded = Disassembler.decode(0x08<<26 | rs<<21 | rt<<16 | imm)
    assert_equal :addi, decoded.mnemonic
    assert_equal [[:rt,rt],[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_addi_negative_immediate
    rt = 10; rs = 20; imm = -30
    decoded = Disassembler.decode(0x08<<26 | rs<<21 | rt<<16 | 0x10000+imm)
    assert_equal :addi, decoded.mnemonic
    assert_equal [[:rt,rt],[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_addiu
    rt = 10; rs = 20; imm = 30
    decoded = Disassembler.decode(0x09<<26 | rs<<21 | rt<<16 | imm)
    assert_equal :addiu, decoded.mnemonic
    assert_equal [[:rt,rt],[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_addiu_negative_immediate
    rt = 10; rs = 20; imm = -30
    decoded = Disassembler.decode(0x09<<26 | rs<<21 | rt<<16 | 0x10000+imm)
    assert_equal decoded.mnemonic, :addiu
    assert_equal decoded.operands, [[:rt,rt],[:rs,rs],[:simm,imm]]
  end

  def test_addu
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x21)
    assert_equal :addu, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_and
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x24)
    assert_equal :and, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_andi
    rt = 10; rs = 20; imm = 0xcdef
    decoded = Disassembler.decode(0x0c<<26 | rs<<21 | rt<<16 | imm)
    assert_equal :andi, decoded.mnemonic
    assert_equal [[:rt,rt],[:rs,rs],[:uimm,imm]], decoded.operands
  end

  def test_bc0f
    offset = 30
    decoded = Disassembler.decode(0x10<<26 | 0x08<<21 | offset)
    assert_equal :bc0f, decoded.mnemonic
    assert_equal [[:offset,offset]], decoded.operands
  end

  def test_bc1f
    offset = 30
    decoded = Disassembler.decode(0x11<<26 | 0x08<<21 | offset)
    assert_equal :bc1f, decoded.mnemonic
    assert_equal [[:offset,offset]], decoded.operands
  end

  def test_bc2f
    offset = 30
    decoded = Disassembler.decode(0x12<<26 | 0x08<<21 | offset)
    assert_equal :bc2f, decoded.mnemonic
    assert_equal [[:offset,offset]], decoded.operands
  end

  def test_bc0fl
    offset = 30
    decoded = Disassembler.decode(0x10<<26 | 0x08<<21 | 0x02<<16 | offset)
    assert_equal :bc0fl, decoded.mnemonic
    assert_equal [[:offset,offset]], decoded.operands
  end

  def test_bc1fl
    offset = 30
    decoded = Disassembler.decode(0x11<<26 | 0x08<<21 | 0x02<<16 | offset)
    assert_equal :bc1fl, decoded.mnemonic
    assert_equal [[:offset,offset]], decoded.operands
  end

  def test_bc2fl
    offset = 30
    decoded = Disassembler.decode(0x12<<26 | 0x08<<21 | 0x02<<16 | offset)
    assert_equal :bc2fl, decoded.mnemonic
    assert_equal [[:offset,offset]], decoded.operands
  end

  def test_bc0t
    offset = 30
    decoded = Disassembler.decode(0x10<<26 | 0x08<<21 | 0x01<<16 | offset)
    assert_equal :bc0t, decoded.mnemonic
    assert_equal [[:offset,offset]], decoded.operands
  end

  def test_bc1t
    offset = 30
    decoded = Disassembler.decode(0x11<<26 | 0x08<<21 | 0x01<<16 | offset)
    assert_equal :bc1t, decoded.mnemonic
    assert_equal [[:offset,offset]], decoded.operands
  end

  def test_bc2t
    offset = 30
    decoded = Disassembler.decode(0x12<<26 | 0x08<<21 | 0x01<<16 | offset)
    assert_equal :bc2t, decoded.mnemonic
    assert_equal [[:offset,offset]], decoded.operands
  end

  def test_bc0tl
    offset = 30
    decoded = Disassembler.decode(0x10<<26 | 0x08<<21 | 0x03<<16 | offset)
    assert_equal :bc0tl, decoded.mnemonic
    assert_equal [[:offset,offset]], decoded.operands
  end

  def test_bc1tl
    offset = 30
    decoded = Disassembler.decode(0x11<<26 | 0x08<<21 | 0x03<<16 | offset)
    assert_equal :bc1tl, decoded.mnemonic
    assert_equal [[:offset,offset]], decoded.operands
  end

  def test_bc2tl
    offset = 30
    decoded = Disassembler.decode(0x12<<26 | 0x08<<21 | 0x03<<16 | offset)
    assert_equal :bc2tl, decoded.mnemonic
    assert_equal [[:offset,offset]], decoded.operands
  end

  def test_beq
    rs = 10; rt = 20; offset = 30
    decoded = Disassembler.decode(0x04<<26 | rs<<21 | rt<<16 | offset)
    assert_equal :beq, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt],[:offset,offset]], decoded.operands
  end

  def test_beql
    rs = 10; rt = 20; offset = 30
    decoded = Disassembler.decode(0x14<<26 | rs<<21 | rt<<16 | offset)
    assert_equal :beql, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt],[:offset,offset]], decoded.operands
  end

  def test_bgez
    rs = 10; offset = 30
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x01<<16 | offset)
    assert_equal :bgez, decoded.mnemonic
    assert_equal [[:rs,rs],[:offset,offset]], decoded.operands
  end

  def test_bgezal
    rs = 10; offset = 30
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x11<<16 | offset)
    assert_equal :bgezal, decoded.mnemonic
    assert_equal [[:rs,rs],[:offset,offset]], decoded.operands
  end

  def test_bgezall
    rs = 10; offset = 30
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x13<<16 | offset)
    assert_equal :bgezall, decoded.mnemonic
    assert_equal [[:rs,rs],[:offset,offset]], decoded.operands
  end

  def test_bgezl
    rs = 10; offset = 30
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x03<<16 | offset)
    assert_equal :bgezl, decoded.mnemonic
    assert_equal [[:rs,rs],[:offset,offset]], decoded.operands
  end

  def test_bgtz
    rs = 10; offset = 30
    decoded = Disassembler.decode(0x07<<26 | rs<<21 | offset)
    assert_equal :bgtz, decoded.mnemonic
    assert_equal [[:rs,rs],[:offset,offset]], decoded.operands
  end

  def test_bgtzl
    rs = 10; offset = 30
    decoded = Disassembler.decode(0x17<<26 | rs<<21 | offset)
    assert_equal :bgtzl, decoded.mnemonic
    assert_equal [[:rs,rs],[:offset,offset]], decoded.operands
  end

  def test_blez
    rs = 10; offset = 30
    decoded = Disassembler.decode(0x06<<26 | rs<<21 | offset)
    assert_equal :blez, decoded.mnemonic
    assert_equal [[:rs,rs],[:offset,offset]], decoded.operands
  end

  def test_blezl
    rs = 10; offset = 30
    decoded = Disassembler.decode(0x16<<26 | rs<<21 | offset)
    assert_equal :blezl, decoded.mnemonic
    assert_equal [[:rs,rs],[:offset,offset]], decoded.operands
  end

  def test_bltz
    rs = 10; offset = 30
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | offset)
    assert_equal :bltz, decoded.mnemonic
    assert_equal [[:rs,rs],[:offset,offset]], decoded.operands
  end

  def test_bltzal
    rs = 10; offset = 30
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x10<<16 | offset)
    assert_equal :bltzal, decoded.mnemonic
    assert_equal [[:rs,rs],[:offset,offset]], decoded.operands
  end

  def test_bltzall
    rs = 10; offset = 30
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x12<<16 | offset)
    assert_equal :bltzall, decoded.mnemonic
    assert_equal [[:rs,rs],[:offset,offset]], decoded.operands
  end

  def test_bltzl
    rs = 10; offset = 30
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x02<<16 | offset)
    assert_equal :bltzl, decoded.mnemonic
    assert_equal [[:rs,rs],[:offset,offset]], decoded.operands
  end

  def test_bne
    rs = 10; rt = 20; offset = 30
    decoded = Disassembler.decode(0x05<<26 | rs<<21 | rt<<16 | offset)
    assert_equal :bne, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt],[:offset,offset]], decoded.operands
  end

  def test_bnel
    rs = 10; rt = 20; offset = 30
    decoded = Disassembler.decode(0x15<<26 | rs<<21 | rt<<16 | offset)
    assert_equal :bnel, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt],[:offset,offset]], decoded.operands
  end

  def test_break
    code = 10
    decoded = Disassembler.decode(code<<6 | 0x0d)
    assert_equal :break, decoded.mnemonic
    assert_equal [[:syscall_code,code]], decoded.operands
  end

  def test_cache
    op = 10; base = 20; offset = 30
    decoded = Disassembler.decode(0x2f<<26 | base<<21 | op<<16 | offset)
    assert_equal :cache, decoded.mnemonic
    assert_equal [[:rt,op],[:simm,offset],[:base,base]], decoded.operands
  end

  def test_cfc1
    rt = 10; rd = 20
    decoded = Disassembler.decode(0x11<<26 | 0x02<<21 | rt<<16 | rd<<11)
    assert_equal :cfc1, decoded.mnemonic
    assert_equal [[:rt,rt],[:rd,rd]], decoded.operands
  end

  def test_cfc2
    rt = 10; rd = 20
    decoded = Disassembler.decode(0x12<<26 | 0x02<<21 | rt<<16 | rd<<11)
    assert_equal :cfc2, decoded.mnemonic
    assert_equal [[:rt,rt],[:rd,rd]], decoded.operands
  end

  def test_ctc1
    rt = 10; rd = 20
    decoded = Disassembler.decode(0x11<<26 | 0x06<<21 | rt<<16 | rd<<11)
    assert_equal :ctc1, decoded.mnemonic
    assert_equal [[:rt,rt],[:rd,rd]], decoded.operands
  end

  def test_ctc2
    rt = 10; rd = 20
    decoded = Disassembler.decode(0x12<<26 | 0x06<<21 | rt<<16 | rd<<11)
    assert_equal :ctc2, decoded.mnemonic
    assert_equal [[:rt,rt],[:rd,rd]], decoded.operands
  end

  def test_dadd
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x2c)
    assert_equal :dadd, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_daddi
    rt = 10; rs = 20; imm = 30
    decoded = Disassembler.decode(0x18<<26 | rs<<21 | rt<<16 | imm)
    assert_equal :daddi, decoded.mnemonic
    assert_equal [[:rt,rt],[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_daddiu
    rt = 10; rs = 20; imm = 30
    decoded = Disassembler.decode(0x19<<26 | rs<<21 | rt<<16 | imm)
    assert_equal :daddiu, decoded.mnemonic
    assert_equal [[:rt,rt],[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_daddu
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x2d)
    assert_equal :daddu, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_ddiv
    rs = 10; rt = 20
    decoded = Disassembler.decode(rs<<21 | rt<<16 | 0x1e)
    assert_equal :ddiv, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_ddivu
    rs = 10; rt = 20
    decoded = Disassembler.decode(rs<<21 | rt<<16 | 0x1f)
    assert_equal :ddivu, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_div
    rs = 10; rt = 20
    decoded = Disassembler.decode(rs<<21 | rt<<16 | 0x1a)
    assert_equal :div, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_divu
    rs = 10; rt = 20
    decoded = Disassembler.decode(rs<<21 | rt<<16 | 0x1b)
    assert_equal :divu, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_dmfc0
    rt = 10; rd = 20
    decoded = Disassembler.decode(0x10<<26 | 0x01<<21 | rt<<16 | rd<<11)
    assert_equal :dmfc0, decoded.mnemonic
    assert_equal [[:rt,rt],[:cp0r,rd]], decoded.operands
  end

  def test_dmtc0
    rt = 10; rd = 20
    decoded = Disassembler.decode(0x10<<26 | 0x05<<21 | rt<<16 | rd<<11)
    assert_equal :dmtc0, decoded.mnemonic
    assert_equal [[:rt,rt],[:cp0r,rd]], decoded.operands
  end

  def test_dmult
    rs = 10; rt = 20
    decoded = Disassembler.decode(rs<<21 | rt<<16 | 0x1c)
    assert_equal :dmult, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_dmultu
    rs = 10; rt = 20
    decoded = Disassembler.decode(rs<<21 | rt<<16 | 0x1d)
    assert_equal :dmultu, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_dsll
    rd = 10; rt = 20; sa = 30
    decoded = Disassembler.decode(rt<<16 | rd<<11 | sa<<6 | 0x38)
    assert_equal :dsll, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:sa,sa]], decoded.operands
  end

  def test_dsllv
    rd = 10; rt = 20; rs = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x14)
    assert_equal :dsllv, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:rs,rs]], decoded.operands
  end

  def test_dsll32
    rd = 10; rt = 20; sa = 30
    decoded = Disassembler.decode(rt<<16 | rd<<11 | sa<<6 | 0x3c)
    assert_equal :dsll32, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:sa,sa]], decoded.operands
  end

  def test_dsra
    rd = 10; rt = 20; sa = 30
    decoded = Disassembler.decode(rt<<16 | rd<<11 | sa<<6 | 0x3b)
    assert_equal :dsra, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:sa,sa]], decoded.operands
  end

  def test_dsrav
    rd = 10; rt = 20; rs = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x17)
    assert_equal :dsrav, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:rs,rs]], decoded.operands
  end

  def test_dsra32
    rd = 10; rt = 20; sa = 30
    decoded = Disassembler.decode(rt<<16 | rd<<11 | sa<<6 | 0x3f)
    assert_equal :dsra32, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:sa,sa]], decoded.operands
  end

  def test_dsrl
    rd = 10; rt = 20; sa = 30
    decoded = Disassembler.decode(rt<<16 | rd<<11 | sa<<6 | 0x3a)
    assert_equal :dsrl, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:sa,sa]], decoded.operands
  end

  def test_dsrlv
    rd = 10; rt = 20; rs = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x16)
    assert_equal :dsrlv, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:rs,rs]], decoded.operands
  end

  def test_dsrl32
    rd = 10; rt = 20; sa = 30
    decoded = Disassembler.decode(rt<<16 | rd<<11 | sa<<6 | 0x3e)
    assert_equal :dsrl32, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:sa,sa]], decoded.operands
  end

  def test_dsub
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x2e)
    assert_equal :dsub, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_dsubu
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x2f)
    assert_equal :dsubu, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_eret
    decoded = Disassembler.decode(0x10<<26 | 1<<25 | 0x18)
    assert_equal :eret, decoded.mnemonic
    assert_equal [], decoded.operands
  end

  def test_j
    target = 0x12468
    decoded = Disassembler.decode(0x02<<26 | target)
    assert_equal :j, decoded.mnemonic
    assert_equal [[:target,target]], decoded.operands
  end

  def test_jal
    target = 0x12468
    decoded = Disassembler.decode(0x03<<26 | target)
    assert_equal :jal, decoded.mnemonic
    assert_equal [[:target,target]], decoded.operands
  end

  def test_jalr
    rd = 10; rs = 20
    decoded = Disassembler.decode(rs<<21 | rd<<11 | 0x09)
    assert_equal :jalr, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs]], decoded.operands
  end

  def test_jr
    rs = 10
    decoded = Disassembler.decode(rs<<21 | 0x08)
    assert_equal :jr, decoded.mnemonic
    assert_equal [[:rs,rs]], decoded.operands
  end

  def test_lb
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x20<<26 | base<<21 | rt<<16 | offset)
    assert_equal :lb, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_lbu
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x24<<26 | base<<21 | rt<<16 | offset)
    assert_equal :lbu, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_ld
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x37<<26 | base<<21 | rt<<16 | offset)
    assert_equal :ld, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_ldc1
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x35<<26 | base<<21 | rt<<16 | offset)
    assert_equal :ldc1, decoded.mnemonic
    assert_equal [[:ft,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_ldc2
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x36<<26 | base<<21 | rt<<16 | offset)
    assert_equal :ldc2, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_ldl
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x1a<<26 | base<<21 | rt<<16 | offset)
    assert_equal :ldl, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_ldr
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x1b<<26 | base<<21 | rt<<16 | offset)
    assert_equal :ldr, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_lh
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x21<<26 | base<<21 | rt<<16 | offset)
    assert_equal :lh, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_lhu
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x25<<26 | base<<21 | rt<<16 | offset)
    assert_equal :lhu, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_ll
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x30<<26 | base<<21 | rt<<16 | offset)
    assert_equal :ll, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_lld
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x34<<26 | base<<21 | rt<<16 | offset)
    assert_equal :lld, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_lui
    rt = 10; imm = 20
    decoded = Disassembler.decode(0x0f<<26 | rt<<16 | imm)
    assert_equal :lui, decoded.mnemonic
    assert_equal [[:rt,rt],[:uimm,20]], decoded.operands
  end

  def test_lw
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x23<<26 | base<<21 | rt<<16 | offset)
    assert_equal :lw, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_lwc1
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x31<<26 | base<<21 | rt<<16 | offset)
    assert_equal :lwc1, decoded.mnemonic
    assert_equal [[:ft,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_lwc2
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x32<<26 | base<<21 | rt<<16 | offset)
    assert_equal :lwc2, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_lwl
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x22<<26 | base<<21 | rt<<16 | offset)
    assert_equal :lwl, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_lwr
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x26<<26 | base<<21 | rt<<16 | offset)
    assert_equal :lwr, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_lwu
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x27<<26 | base<<21 | rt<<16 | offset)
    assert_equal :lwu, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_mfc0
    rt = 10; rd = 20
    decoded = Disassembler.decode(0x10<<26 | rt<<16 | rd<<11)
    assert_equal :mfc0, decoded.mnemonic
    assert_equal [[:rt,rt],[:cp0r,rd]], decoded.operands
  end

  def test_mfc1
    rt = 10; rd = 20
    decoded = Disassembler.decode(0x11<<26 | rt<<16 | rd<<11)
    assert_equal :mfc1, decoded.mnemonic
    assert_equal [[:rt,rt],[:rd,rd]], decoded.operands
  end

  def test_mfc2
    rt = 10; rd = 20
    decoded = Disassembler.decode(0x12<<26 | rt<<16 | rd<<11)
    assert_equal :mfc2, decoded.mnemonic
    assert_equal [[:rt,rt],[:rd,rd]], decoded.operands
  end

  def test_mfhi
    rd = 10
    decoded = Disassembler.decode(rd<<11 | 0x10)
    assert_equal :mfhi, decoded.mnemonic
    assert_equal [[:rd,rd]], decoded.operands
  end

  def test_mflo
    rd = 10
    decoded = Disassembler.decode(rd<<11 | 0x12)
    assert_equal :mflo, decoded.mnemonic
    assert_equal [[:rd,rd]], decoded.operands
  end

  def test_mtc0
    rt = 10; rd = 20
    decoded = Disassembler.decode(0x10<<26 | 0x04<<21 | rt<<16 | rd<<11)
    assert_equal :mtc0, decoded.mnemonic
    assert_equal [[:rt,rt],[:cp0r,rd]], decoded.operands
  end

  def test_mtc1
    rt = 10; rd = 20
    decoded = Disassembler.decode(0x11<<26 | 0x04<<21 | rt<<16 | rd<<11)
    assert_equal :mtc1, decoded.mnemonic
    assert_equal [[:rt,rt],[:rd,rd]], decoded.operands
  end

  def test_mtc2
    rt = 10; rd = 20
    decoded = Disassembler.decode(0x12<<26 | 0x04<<21 | rt<<16 | rd<<11)
    assert_equal :mtc2, decoded.mnemonic
    assert_equal [[:rt,rt],[:rd,rd]], decoded.operands
  end

  def test_mthi
    rs = 10
    decoded = Disassembler.decode(rs<<21 | 0x11)
    assert_equal :mthi, decoded.mnemonic
    assert_equal [[:rs,rs]], decoded.operands
  end

  def test_mtlo
    rs = 10
    decoded = Disassembler.decode(rs<<21 | 0x13)
    assert_equal :mtlo, decoded.mnemonic
    assert_equal [[:rs,rs]], decoded.operands
  end

  def test_mult
    rs = 10; rt = 20
    decoded = Disassembler.decode(rs<<21 | rt<<16 | 0x18)
    assert_equal :mult, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_multu
    rs = 10; rt = 20
    decoded = Disassembler.decode(rs<<21 | rt<<16 | 0x19)
    assert_equal :multu, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_nor
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x27)
    assert_equal :nor, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_or
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x25)
    assert_equal :or, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_ori
    rt = 10; rs = 20; imm = 30
    decoded = Disassembler.decode(0x0d<<26 | rs<<21 | rt<<16 | imm)
    assert_equal :ori, decoded.mnemonic
    assert_equal [[:rt,rt],[:rs,rs],[:uimm,imm]], decoded.operands
  end

  def test_sb
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x28<<26 | base<<21 | rt<<16 | offset)
    assert_equal :sb, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_sc
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x38<<26 | base<<21 | rt<<16 | offset)
    assert_equal :sc, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_scd
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x3c<<26 | base<<21 | rt<<16 | offset)
    assert_equal :scd, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_sd
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x3f<<26 | base<<21 | rt<<16 | offset)
    assert_equal :sd, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_sdc1
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x3d<<26 | base<<21 | rt<<16 | offset)
    assert_equal :sdc1, decoded.mnemonic
    assert_equal [[:ft,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_sdc2
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x3e<<26 | base<<21 | rt<<16 | offset)
    assert_equal :sdc2, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_sdl
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x2c<<26 | base<<21 | rt<<16 | offset)
    assert_equal :sdl, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_sdr
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x2d<<26 | base<<21 | rt<<16 | offset)
    assert_equal :sdr, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_sh
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x29<<26 | base<<21 | rt<<16 | offset)
    assert_equal :sh, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_sll
    rd = 10; rt = 20; sa = 30
    decoded = Disassembler.decode(rt<<16 | rd<<11 | sa<<6)
    assert_equal :sll, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:sa,sa]], decoded.operands
  end

  def test_sllv
    rd = 10; rt = 20; rs = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x04)
    assert_equal :sllv, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:rs,rs]], decoded.operands
  end

  def test_slt
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x2a)
    assert_equal :slt, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_slti
    rt = 10; rs = 20; imm = 30
    decoded = Disassembler.decode(0x0a<<26 | rs<<21 | rt<<16 | imm)
    assert_equal :slti, decoded.mnemonic
    assert_equal [[:rt,rt],[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_sltiu
    rt = 10; rs = 20; imm = 30
    decoded = Disassembler.decode(0x0b<<26 | rs<<21 | rt<<16 | imm)
    assert_equal :sltiu, decoded.mnemonic
    assert_equal [[:rt,rt],[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_sltu
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x2b)
    assert_equal :sltu, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_sra
    rd = 10; rt = 20; sa = 30
    decoded = Disassembler.decode(rt<<16 | rd<<11 | sa<<6 | 0x03)
    assert_equal :sra, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:sa,sa]], decoded.operands
  end

  def test_srav
    rd = 10; rt = 20; rs = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x07)
    assert_equal :srav, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:rs,rs]], decoded.operands
  end

  def test_srl
    rd = 10; rt = 20; sa = 30
    decoded = Disassembler.decode(rt<<16 | rd<<11 | sa<<6 | 0x02)
    assert_equal :srl, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:sa,sa]], decoded.operands
  end

  def test_srlv
    rd = 10; rt = 20; rs = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x06)
    assert_equal :srlv, decoded.mnemonic
    assert_equal [[:rd,rd],[:rt,rt],[:rs,rs]], decoded.operands
  end

  def test_sub
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x22)
    assert_equal :sub, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_subu
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x23)
    assert_equal :subu, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_sw
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x2b<<26 | base<<21 | rt<<16 | offset)
    assert_equal :sw, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_swc1
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x39<<26 | base<<21 | rt<<16 | offset)
    assert_equal :swc1, decoded.mnemonic
    assert_equal [[:ft,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_swc2
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x3a<<26 | base<<21 | rt<<16 | offset)
    assert_equal :swc2, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_swl
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x2a<<26 | base<<21 | rt<<16 | offset)
    assert_equal :swl, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_swr
    rt = 10; offset = 20; base = 30
    decoded = Disassembler.decode(0x2e<<26 | base<<21 | rt<<16 | offset)
    assert_equal :swr, decoded.mnemonic
    assert_equal [[:rt,rt],[:simm,20],[:base,base]], decoded.operands
  end

  def test_sync
    decoded = Disassembler.decode(0x0f)
    assert_equal :sync, decoded.mnemonic
    assert_equal [], decoded.operands
  end

  def test_syscall
    code = 10
    decoded = Disassembler.decode(code<<6 | 0x0c)
    assert_equal :syscall, decoded.mnemonic
    assert_equal [[:syscall_code,code]], decoded.operands
  end

  def test_teq
    rs = 10; rt = 20; code = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | code<<6 | 0x34)
    assert_equal :teq, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt],[:trap_code,code]], decoded.operands
  end

  def test_teqi
    rs = 10; imm = 20
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x0c<<16 | imm)
    assert_equal :teqi, decoded.mnemonic
    assert_equal [[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_tge
    rs = 10; rt = 20; code = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | code<<6 | 0x30)
    assert_equal :tge, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt],[:trap_code,code]], decoded.operands
  end

  def test_tgei
    rs = 10; imm = 20
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x08<<16 | imm)
    assert_equal :tgei, decoded.mnemonic
    assert_equal [[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_tgeiu
    rs = 10; imm = 20
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x09<<16 | imm)
    assert_equal :tgeiu, decoded.mnemonic
    assert_equal [[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_tgeu
    rs = 10; rt = 20; code = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | code<<6 | 0x31)
    assert_equal :tgeu, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt],[:trap_code,code]], decoded.operands
  end

  def test_tlbp
    decoded = Disassembler.decode(0x10<<26 | 0x01<<25 | 0x08)
    assert_equal :tlbp, decoded.mnemonic
    assert_equal [], decoded.operands
  end

  def test_tlbr
    decoded = Disassembler.decode(0x10<<26 | 0x01<<25 | 0x01)
    assert_equal :tlbr, decoded.mnemonic
    assert_equal [], decoded.operands
  end

  def test_tlbwi
    decoded = Disassembler.decode(0x10<<26 | 0x01<<25 | 0x02)
    assert_equal :tlbwi, decoded.mnemonic
    assert_equal [], decoded.operands
  end

  def test_tlbwr
    decoded = Disassembler.decode(0x10<<26 | 0x01<<25 | 0x06)
    assert_equal :tlbwr, decoded.mnemonic
    assert_equal [], decoded.operands
  end

  def test_tlt
    rs = 10; rt = 20; code = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | code<<6 | 0x32)
    assert_equal :tlt, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt],[:trap_code,code]], decoded.operands
  end

  def test_tlti
    rs = 10; imm = 20
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x0a<<16 | imm)
    assert_equal :tlti, decoded.mnemonic
    assert_equal [[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_tltiu
    rs = 10; imm = 20
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x0b<<16 | imm)
    assert_equal :tltiu, decoded.mnemonic
    assert_equal [[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_tltu
    rs = 10; rt = 20; code = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | code<<6 | 0x33)
    assert_equal :tltu, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt],[:trap_code,code]], decoded.operands
  end

  def test_tne
    rs = 10; rt = 20; code = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | code<<6 | 0x36)
    assert_equal :tne, decoded.mnemonic
    assert_equal [[:rs,rs],[:rt,rt],[:trap_code,code]], decoded.operands
  end

  def test_tnei
    rs = 10; imm = 20
    decoded = Disassembler.decode(0x01<<26 | rs<<21 | 0x0e<<16 | imm)
    assert_equal :tnei, decoded.mnemonic
    assert_equal [[:rs,rs],[:simm,imm]], decoded.operands
  end

  def test_xor
    rd = 10; rs = 20; rt = 30
    decoded = Disassembler.decode(rs<<21 | rt<<16 | rd<<11 | 0x26)
    assert_equal :xor, decoded.mnemonic
    assert_equal [[:rd,rd],[:rs,rs],[:rt,rt]], decoded.operands
  end

  def test_xori
    rt = 10; rs = 20; imm = 30
    decoded = Disassembler.decode(0x0e<<26 | rs<<21 | rt<<16 | imm)
    assert_equal :xori, decoded.mnemonic
    assert_equal [[:rt,rt],[:rs,rs],[:uimm,imm]], decoded.operands
  end

  define_method :'test_abs.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x05)
    assert_equal :'abs.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_abs.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x05)
    assert_equal :'abs.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_add.s' do
    fd = 10; fs = 20; ft = 30
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | fd<<6)
    assert_equal :'add.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_add.d' do
    fd = 10; fs = 20; ft = 30
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | fd<<6)
    assert_equal :'add.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.f.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x30)
    assert_equal :'c.f.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.un.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x31)
    assert_equal :'c.un.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.eq.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x32)
    assert_equal :'c.eq.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ueq.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x33)
    assert_equal :'c.ueq.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.olt.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x34)
    assert_equal :'c.olt.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ult.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x35)
    assert_equal :'c.ult.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ole.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x36)
    assert_equal :'c.ole.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ule.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x37)
    assert_equal :'c.ule.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.sf.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x38)
    assert_equal :'c.sf.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ngle.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x39)
    assert_equal :'c.ngle.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.seq.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x3a)
    assert_equal :'c.seq.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ngl.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x3b)
    assert_equal :'c.ngl.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.lt.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x3c)
    assert_equal :'c.lt.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.nge.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x3d)
    assert_equal :'c.nge.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.le.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x3e)
    assert_equal :'c.le.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ngt.s' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x3f)
    assert_equal :'c.ngt.s', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.f.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x30)
    assert_equal :'c.f.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.un.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x31)
    assert_equal :'c.un.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.eq.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x32)
    assert_equal :'c.eq.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ueq.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x33)
    assert_equal :'c.ueq.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.olt.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x34)
    assert_equal :'c.olt.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ult.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x35)
    assert_equal :'c.ult.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ole.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x36)
    assert_equal :'c.ole.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ule.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x37)
    assert_equal :'c.ule.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.sf.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x38)
    assert_equal :'c.sf.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ngle.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x39)
    assert_equal :'c.ngle.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.seq.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x3a)
    assert_equal :'c.seq.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ngl.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x3b)
    assert_equal :'c.ngl.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.lt.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x3c)
    assert_equal :'c.lt.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.nge.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x3d)
    assert_equal :'c.nge.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.le.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x3e)
    assert_equal :'c.le.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_c.ngt.d' do
    fs = 10; ft = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x3f)
    assert_equal :'c.ngt.d', decoded.mnemonic
    assert_equal [[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_ceil.l.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x0a)
    assert_equal :'ceil.l.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_ceil.l.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x0a)
    assert_equal :'ceil.l.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_ceil.w.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x0e)
    assert_equal :'ceil.w.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_ceil.w.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x0e)
    assert_equal :'ceil.w.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_cvt.d.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x21)
    assert_equal :'cvt.d.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_cvt.d.w' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x14<<21 | fs<<11 | fd<<6 | 0x21)
    assert_equal :'cvt.d.w', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_cvt.d.l' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x15<<21 | fs<<11 | fd<<6 | 0x21)
    assert_equal :'cvt.d.l', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_cvt.l.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x25)
    assert_equal :'cvt.l.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_cvt.l.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x25)
    assert_equal :'cvt.l.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_cvt.s.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x20)
    assert_equal :'cvt.s.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_cvt.s.w' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x14<<21 | fs<<11 | fd<<6 | 0x20)
    assert_equal :'cvt.s.w', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_cvt.s.l' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x15<<21 | fs<<11 | fd<<6 | 0x20)
    assert_equal :'cvt.s.l', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_cvt.w.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x24)
    assert_equal :'cvt.w.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_cvt.w.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x24)
    assert_equal :'cvt.w.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_div.s' do
    fd = 10; fs = 20; ft = 30
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | fd<<6 | 0x03)
    assert_equal :'div.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_div.d' do
    fd = 10; fs = 20; ft = 30
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | fd<<6 | 0x03)
    assert_equal :'div.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_floor.l.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x0b)
    assert_equal :'floor.l.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_floor.l.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x0b)
    assert_equal :'floor.l.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_floor.w.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x0f)
    assert_equal :'floor.w.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_floor.w.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x0f)
    assert_equal :'floor.w.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_mov.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x06)
    assert_equal :'mov.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_mov.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x06)
    assert_equal :'mov.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_mul.s' do
    fd = 10; fs = 20; ft = 30
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | fd<<6 | 0x02)
    assert_equal :'mul.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_mul.d' do
    fd = 10; fs = 20; ft = 30
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | fd<<6 | 0x02)
    assert_equal :'mul.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_neg.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x07)
    assert_equal :'neg.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_neg.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x07)
    assert_equal :'neg.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_round.l.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x08)
    assert_equal :'round.l.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_round.l.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x08)
    assert_equal :'round.l.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_round.w.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x0c)
    assert_equal :'round.w.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_round.w.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x0c)
    assert_equal :'round.w.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_sqrt.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x04)
    assert_equal :'sqrt.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_sqrt.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x04)
    assert_equal :'sqrt.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_sub.s' do
    fd = 10; fs = 20; ft = 30
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | fd<<6 | 0x01)
    assert_equal :'sub.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_sub.d' do
    fd = 10; fs = 20; ft = 30
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | fd<<6 | 0x01)
    assert_equal :'sub.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs],[:ft,ft]], decoded.operands
  end

  define_method :'test_trunc.l.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x09)
    assert_equal :'trunc.l.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_trunc.l.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x09)
    assert_equal :'trunc.l.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_trunc.w.s' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x0d)
    assert_equal :'trunc.w.s', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end

  define_method :'test_trunc.w.d' do
    fd = 10; fs = 20
    decoded = Disassembler.decode(0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x0d)
    assert_equal :'trunc.w.d', decoded.mnemonic
    assert_equal [[:fd,fd],[:fs,fs]], decoded.operands
  end
end
end
