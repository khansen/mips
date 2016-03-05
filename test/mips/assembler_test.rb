require 'test/unit'
require 'mips'

module Mips
class AssemblerTest < Test::Unit::TestCase #:nodoc:
  def setup
    @_ = Assembler.new
  end

  def test_label_offset
    @_.instance_exec do
      label :foo
      add 10, 20, 30
      bne 10, 10, :foo
      add 10, 20, 30
    end
    assert_equal 0xfffe, @_.instructions[1] & 0xffff
  end

  def test_label_backpatch_offset
    @_.instance_exec do
      bne 10, 10, :foo
      add 10, 20, 30
      label :foo
    end
    assert_equal 1, @_.instructions[0] & 0xffff
  end

  def test_label_target
    @_.instance_exec do
      add 10, 20, 30
      label :foo
      add 10, 20, 30
      j :foo
      add 10, 20, 30
    end
    assert_equal 1, @_.instructions[2] & 0x3ffffff
  end

  def test_label_backpatch_target
    @_.instance_exec do
      j :foo
      add 10, 20, 30
      label :foo
    end
    assert_equal 2, @_.instructions[0] & 0x3ffffff
  end

  def test_add
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x20, @_.add(rd, rs, rt)
  end

  def test_addi
    rt = 10; rs = 20; imm = 30
    assert_equal 0x08<<26 | rs<<21 | rt<<16 | imm, @_.addi(rt, rs, imm)
  end

  def test_addi_negative_immediate
    rt = 10; rs = 20; imm = -30
    assert_equal 0x08<<26 | rs<<21 | rt<<16 | 0x10000+imm, @_.addi(rt, rs, imm)
  end

  def test_addiu
    rt = 10; rs = 20; imm = 30
    assert_equal 0x09<<26 | rs<<21 | rt<<16 | imm, @_.addiu(rt, rs, imm)
  end

  def test_addiu_negative_immediate
    rt = 10; rs = 20; imm = -30
    assert_equal 0x09<<26 | rs<<21 | rt<<16 | 0x10000+imm, @_.addiu(rt, rs, imm)
  end

  def test_addu
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x21, @_.addu(rd, rs, rt)
  end

  def test_and
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x24, @_.and(rd, rs, rt)
  end

  def test_andi
    rt = 10; rs = 20; imm = 30
    assert_equal 0x0C<<26 | rs<<21 | rt<<16 | imm, @_.andi(rt, rs, imm)
  end

  def test_bc0f
    offset = 30
    assert_equal 0x10<<26 | 0x08<<21 | offset, @_.bc0f(offset)
  end

  def test_bc1f
    offset = 30
    assert_equal 0x11<<26 | 0x08<<21 | offset, @_.bc1f(offset)
  end

  def test_bc2f
    offset = 30
    assert_equal 0x12<<26 | 0x08<<21 | offset, @_.bc2f(offset)
  end

  def test_bc0fl
    offset = 30
    assert_equal 0x10<<26 | 0x08<<21 | 0x02<<16 | offset, @_.bc0fl(offset)
  end

  def test_bc1fl
    offset = 30
    assert_equal 0x11<<26 | 0x08<<21 | 0x02<<16 | offset, @_.bc1fl(offset)
  end

  def test_bc2fl
    offset = 30
    assert_equal 0x12<<26 | 0x08<<21 | 0x02<<16 | offset, @_.bc2fl(offset)
  end

  def test_bc0t
    offset = 30
    assert_equal 0x10<<26 | 0x08<<21 | 0x01<<16 | offset, @_.bc0t(offset)
  end

  def test_bc1t
    offset = 30
    assert_equal 0x11<<26 | 0x08<<21 | 0x01<<16 | offset, @_.bc1t(offset)
  end

  def test_bc2t
    offset = 30
    assert_equal 0x12<<26 | 0x08<<21 | 0x01<<16 | offset, @_.bc2t(offset)
  end

  def test_bc0tl
    offset = 30
    assert_equal 0x10<<26 | 0x08<<21 | 0x03<<16 | offset, @_.bc0tl(offset)
  end

  def test_bc1tl
    offset = 30
    assert_equal 0x11<<26 | 0x08<<21 | 0x03<<16 | offset, @_.bc1tl(offset)
  end

  def test_bc2tl
    offset = 30
    assert_equal 0x12<<26 | 0x08<<21 | 0x03<<16 | offset, @_.bc2tl(offset)
  end

  def test_beq
    rs = 10; rt = 20; offset = 30
    assert_equal 0x04<<26 | rs<<21 | rt<<16 | offset, @_.beq(rs, rt, offset)
  end

  def test_beq_negative_offset
    rs = 10; rt = 20; offset = -30
    assert_equal 0x04<<26 | rs<<21 | rt<<16 | 0x10000+offset, @_.beq(rs, rt, offset)
  end

  def test_bgez
    rs = 10; offset = 30
    assert_equal 0x01<<26 | rs<<21 | 0x01<<16 | offset, @_.bgez(rs, offset)
  end

  def test_bgez_negative_offset
    rs = 10; offset = -30
    assert_equal 0x01<<26 | rs<<21 | 0x01<<16 | 0x10000+offset, @_.bgez(rs, offset)
  end

  def test_bgezal
    rs = 10; offset = 30
    assert_equal 0x01<<26 | rs<<21 | 0x11<<16 | offset, @_.bgezal(rs, offset)
  end

  def test_bgezal_negative_offset
    rs = 10; offset = -30
    assert_equal 0x01<<26 | rs<<21 | 0x11<<16 | 0x10000+offset, @_.bgezal(rs, offset)
  end

  def test_bgezl
    rs = 10; offset = 30
    assert_equal 0x01<<26 | rs<<21 | 0x03<<16 | offset, @_.bgezl(rs, offset)
  end

  def test_bgezl_negative_offset
    rs = 10; offset = -30
    assert_equal 0x01<<26 | rs<<21 | 0x03<<16 | 0x10000+offset, @_.bgezl(rs, offset)
  end

  def test_bgtz
    rs = 10; offset = 30
    assert_equal 0x07<<26 | rs<<21 | offset, @_.bgtz(rs, offset)
  end

  def test_bgtz_negative_offset
    rs = 10; offset = -30
    assert_equal 0x07<<26 | rs<<21 | 0x10000+offset, @_.bgtz(rs, offset)
  end

  def test_bgtzl
    rs = 10; offset = 30
    assert_equal 0x17<<26 | rs<<21 | offset, @_.bgtzl(rs, offset)
  end

  def test_bgtzl_negative_offset
    rs = 10; offset = -30
    assert_equal 0x17<<26 | rs<<21 | 0x10000+offset, @_.bgtzl(rs, offset)
  end

  def test_blez
    rs = 10; offset = 30
    assert_equal 0x06<<26 | rs<<21 | offset, @_.blez(rs, offset)
  end

  def test_blez_negative_offset
    rs = 10; offset = -30
    assert_equal 0x06<<26 | rs<<21 | 0x10000+offset, @_.blez(rs, offset)
  end

  def test_blezl
    rs = 10; offset = 30
    assert_equal 0x16<<26 | rs<<21 | offset, @_.blezl(rs, offset)
  end

  def test_blezl_negative_offset
    rs = 10; offset = -30
    assert_equal 0x16<<26 | rs<<21 | 0x10000+offset, @_.blezl(rs, offset)
  end

  def test_bltz
    rs = 10; offset = 30
    assert_equal 0x01<<26 | rs<<21 | offset, @_.bltz(rs, offset)
  end

  def test_bltz_negative_offset
    rs = 10; offset = -30
    assert_equal 0x01<<26 | rs<<21 | 0x10000+offset, @_.bltz(rs, offset)
  end

  def test_bltzal
    rs = 10; offset = 30
    assert_equal 0x01<<26 | rs<<21 | 0x10<<16 | offset, @_.bltzal(rs, offset)
  end

  def test_bltzal_negative_offset
    rs = 10; offset = -30
    assert_equal 0x01<<26 | rs<<21 | 0x10<<16 | 0x10000+offset, @_.bltzal(rs, offset)
  end

  def test_bltzall
    rs = 10; offset = 30
    assert_equal 0x01<<26 | rs<<21 | 0x12<<16 | offset, @_.bltzall(rs, offset)
  end

  def test_bltzall_negative_offset
    rs = 10; offset = -30
    assert_equal 0x01<<26 | rs<<21 | 0x12<<16 | 0x10000+offset, @_.bltzall(rs, offset)
  end

  def test_bltzl
    rs = 10; offset = 30
    assert_equal 0x01<<26 | rs<<21 | 0x02<<16 | offset, @_.bltzl(rs, offset)
  end

  def test_bltzl_negative_offset
    rs = 10; offset = -30
    assert_equal 0x01<<26 | rs<<21 | 0x02<<16 | 0x10000+offset, @_.bltzl(rs, offset)
  end

  def test_bne
    rs = 10; rt = 20; offset = 30
    assert_equal 0x05<<26 | rs<<21 | rt<<16 | offset, @_.bne(rs, rt, offset)
  end

  def test_bne_negative_offset
    rs = 10; rt = 20; offset = -30
    assert_equal 0x05<<26 | rs<<21 | rt<<16 | 0x10000+offset, @_.bne(rs, rt, offset)
  end

  def test_bnel
    rs = 10; rt = 20; offset = 30
    assert_equal 0x15<<26 | rs<<21 | rt<<16 | offset, @_.bnel(rs, rt, offset)
  end

  def test_bnel_negative_offset
    rs = 10; rt = 20; offset = -30
    assert_equal 0x15<<26 | rs<<21 | rt<<16 | 0x10000+offset, @_.bnel(rs, rt, offset)
  end

  def test_break
    code = 10
    assert_equal code<<6 | 0x0d, @_.break(code)
  end

  def test_cache
    op = 10; base = 20; offset = 30
    assert_equal 0x2f<<26 | base<<21 | op<<16 | offset, @_.cache(op, offset, base)
  end

  def test_cache_negative_offset
    op = 10; base = 20; offset = -30
    assert_equal 0x2f<<26 | base<<21 | op<<16 | 0x10000+offset, @_.cache(op, offset, base)
  end

  def test_cfc1
    rt = 10; rd = 20
    assert_equal 0x11<<26 | 0x02<<21 | rt<<16 | rd<<11, @_.cfc1(rt, rd)
  end

  def test_cfc2
    rt = 10; rd = 20
    assert_equal 0x12<<26 | 0x02<<21 | rt<<16 | rd<<11, @_.cfc2(rt, rd)
  end

  def test_ctc1
    rt = 10; rd = 20
    assert_equal 0x11<<26 | 0x06<<21 | rt<<16 | rd<<11, @_.ctc1(rt, rd)
  end

  def test_ctc2
    rt = 10; rd = 20
    assert_equal 0x12<<26 | 0x06<<21 | rt<<16 | rd<<11, @_.ctc2(rt, rd)
  end

  def test_dadd
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x2c, @_.dadd(rd, rs, rt)
  end

  def test_daddi
    rt = 10; rs = 20; imm = 30
    assert_equal 0x18<<26 | rs<<21 | rt<<16 | imm, @_.daddi(rt, rs, imm)
  end

  def test_daddi_negative_immediate
    rt = 10; rs = 20; imm = -30
    assert_equal 0x18<<26 | rs<<21 | rt<<16 | 0x10000+imm, @_.daddi(rt, rs, imm)
  end

  def test_daddiu
    rt = 10; rs = 20; imm = 30
    assert_equal 0x19<<26 | rs<<21 | rt<<16 | imm, @_.daddiu(rt, rs, imm)
  end

  def test_daddiu_negative_immediate
    rt = 10; rs = 20; imm = -30
    assert_equal 0x19<<26 | rs<<21 | rt<<16 | 0x10000+imm, @_.daddiu(rt, rs, imm)
  end

  def test_daddu
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x2d, @_.daddu(rd, rs, rt)
  end

  def test_ddiv
    rs = 10; rt = 20
    assert_equal rs<<21 | rt<<16 | 0x1e, @_.ddiv(rs, rt)
  end

  def test_ddivu
    rs = 10; rt = 20
    assert_equal rs<<21 | rt<<16 | 0x1f, @_.ddivu(rs, rt)
  end

  def test_div
    rs = 10; rt = 20
    assert_equal rs<<21 | rt<<16 | 0x1a, @_.div(rs, rt)
  end

  def test_divu
    rs = 10; rt = 20
    assert_equal rs<<21 | rt<<16 | 0x1b, @_.divu(rs, rt)
  end

  def test_dmfc0
    rt = 10; rd = 20
    assert_equal 0x10<<26 | 0x01<<21 | rt<<16 | rd<<11, @_.dmfc0(rt, rd)
  end

  def test_dmtc0
    rt = 10; rd = 20
    assert_equal 0x10<<26 | 0x05<<21 | rt<<16 | rd<<11, @_.dmtc0(rt, rd)
  end

  def test_dmult
    rs = 10; rt = 20
    assert_equal rs<<21 | rt<<16 | 0x1c, @_.dmult(rs, rt)
  end

  def test_dmultu
    rs = 10; rt = 20
    assert_equal rs<<21 | rt<<16 | 0x1d, @_.dmultu(rs, rt)
  end

  def test_dsll
    rd = 10; rt = 20; sa = 30
    assert_equal rt<<16 | rd<<11 | sa<<6 | 0x38, @_.dsll(rd, rt, sa)
  end

  def test_dsllv
    rd = 10; rt = 20; rs = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x14, @_.dsllv(rd, rt, rs)
  end

  def test_dsll32
    rd = 10; rt = 20; sa = 30
    assert_equal rt<<16 | rd<<11 | sa<<6 | 0x3c, @_.dsll32(rd, rt, sa)
  end

  def test_dsra
    rd = 10; rt = 20; sa = 30
    assert_equal rt<<16 | rd<<11 | sa<<6 | 0x3b, @_.dsra(rd, rt, sa)
  end

  def test_dsrav
    rd = 10; rt = 20; rs = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x17, @_.dsrav(rd, rt, rs)
  end

  def test_dsra32
    rd = 10; rt = 20; sa = 30
    assert_equal rt<<16 | rd<<11 | sa<<6 | 0x3f, @_.dsra32(rd, rt, sa)
  end

  def test_dsrl
    rd = 10; rt = 20; sa = 30
    assert_equal rt<<16 | rd<<11 | sa<<6 | 0x3a, @_.dsrl(rd, rt, sa)
  end

  def test_dsrlv
    rd = 10; rt = 20; rs = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x16, @_.dsrlv(rd, rt, rs)
  end

  def test_dsrl32
    rd = 10; rt = 20; sa = 30
    assert_equal rt<<16 | rd<<11 | sa<<6 | 0x3e, @_.dsrl32(rd, rt, sa)
  end

  def test_dsub
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x2e, @_.dsub(rd, rs, rt)
  end

  def test_dsubu
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x2f, @_.dsubu(rd, rs, rt)
  end

  def test_eret
    assert_equal 0x10<<26 | 1<<25 | 0x18, @_.eret
  end

  def test_j
    target = 0x0C080408
    assert_equal 0x02<<26 | target>>2, @_.j(target)
  end

  def test_jal
    target = 0x0C080408
    assert_equal 0x03<<26 | target>>2, @_.jal(target)
  end

  def test_jalr
    rd = 10; rs = 20
    assert_equal rs<<21 | rd<<11 | 0x09, @_.jalr(rd, rs)
  end

  def test_jr
    rs = 10
    assert_equal rs<<21 | 0x08, @_.jr(rs)
  end

  def test_lb
    rt = 10; offset = 20; base = 30
    assert_equal 0x20<<26 | base<<21 | rt<<16 | offset, @_.lb(rt, offset, base)
  end

  def test_lb_negative_offset
    rt = 10; offset = -20; base = 30
    assert_equal 0x20<<26 | base<<21 | rt<<16 | 0x10000+offset, @_.lb(rt, offset, base)
  end

  def test_lbu
    rt = 10; offset = 20; base = 30
    assert_equal 0x24<<26 | base<<21 | rt<<16 | offset, @_.lbu(rt, offset, base)
  end

  def test_lbu_negative_offset
    rt = 10; offset = -20; base = 30
    assert_equal 0x24<<26 | base<<21 | rt<<16 | 0x10000+offset, @_.lbu(rt, offset, base)
  end

  def test_ld
    rt = 10; offset = 20; base = 30
    assert_equal 0x37<<26 | base<<21 | rt<<16 | offset, @_.ld(rt, offset, base)
  end

  def test_ldc1
    rt = 10; offset = 20; base = 30
    assert_equal 0x35<<26 | base<<21 | rt<<16 | offset, @_.ldc1(rt, offset, base)
  end

  def test_ldc2
    rt = 10; offset = 20; base = 30
    assert_equal 0x36<<26 | base<<21 | rt<<16 | offset, @_.ldc2(rt, offset, base)
  end

  def test_ldl
    rt = 10; offset = 20; base = 30
    assert_equal 0x1a<<26 | base<<21 | rt<<16 | offset, @_.ldl(rt, offset, base)
  end

  def test_ldr
    rt = 10; offset = 20; base = 30
    assert_equal 0x1b<<26 | base<<21 | rt<<16 | offset, @_.ldr(rt, offset, base)
  end

  def test_lh
    rt = 10; offset = 20; base = 30
    assert_equal 0x21<<26 | base<<21 | rt<<16 | offset, @_.lh(rt, offset, base)
  end

  def test_lhu
    rt = 10; offset = 20; base = 30
    assert_equal 0x25<<26 | base<<21 | rt<<16 | offset, @_.lhu(rt, offset, base)
  end

  def test_ll
    rt = 10; offset = 20; base = 30
    assert_equal 0x30<<26 | base<<21 | rt<<16 | offset, @_.ll(rt, offset, base)
  end

  def test_lld
    rt = 10; offset = 20; base = 30
    assert_equal 0x34<<26 | base<<21 | rt<<16 | offset, @_.lld(rt, offset, base)
  end

  def test_lui
    rt = 10; imm = 20
    assert_equal 0x0f<<26 | rt<<16 | imm, @_.lui(rt, imm)
  end

  def test_lw
    rt = 10; offset = 20; base = 30
    assert_equal 0x23<<26 | base<<21 | rt<<16 | offset, @_.lw(rt, offset, base)
  end

  def test_lwc1
    rt = 10; offset = 20; base = 30
    assert_equal 0x31<<26 | base<<21 | rt<<16 | offset, @_.lwc1(rt, offset, base)
  end

  def test_lwc2
    rt = 10; offset = 20; base = 30
    assert_equal 0x32<<26 | base<<21 | rt<<16 | offset, @_.lwc2(rt, offset, base)
  end

  def test_lwl
    rt = 10; offset = 20; base = 30
    assert_equal 0x22<<26 | base<<21 | rt<<16 | offset, @_.lwl(rt, offset, base)
  end

  def test_lwr
    rt = 10; offset = 20; base = 30
    assert_equal 0x26<<26 | base<<21 | rt<<16 | offset, @_.lwr(rt, offset, base)
  end

  def test_lwu
    rt = 10; offset = 20; base = 30
    assert_equal 0x27<<26 | base<<21 | rt<<16 | offset, @_.lwu(rt, offset, base)
  end

  def test_mfc0
    rt = 10; rd = 20
    assert_equal 0x10<<26 | rt<<16 | rd<<11, @_.mfc0(rt, rd)
  end

  def test_mfc1
    rt = 10; rd = 20
    assert_equal 0x11<<26 | rt<<16 | rd<<11, @_.mfc1(rt, rd)
  end

  def test_mfc2
    rt = 10; rd = 20
    assert_equal 0x12<<26 | rt<<16 | rd<<11, @_.mfc2(rt, rd)
  end

  def test_mfhi
    rd = 10
    assert_equal rd<<11 | 0x10, @_.mfhi(rd)
  end

  def test_mflo
    rd = 10
    assert_equal rd<<11 | 0x12, @_.mflo(rd)
  end

  def test_mtc0
    rt = 10; rd = 20
    assert_equal 0x10<<26 | 0x04<<21 | rt<<16 | rd<<11, @_.mtc0(rt, rd)
  end

  def test_mtc1
    rt = 10; rd = 20
    assert_equal 0x11<<26 | 0x04<<21 | rt<<16 | rd<<11, @_.mtc1(rt, rd)
  end

  def test_mtc2
    rt = 10; rd = 20
    assert_equal 0x12<<26 | 0x04<<21 | rt<<16 | rd<<11, @_.mtc2(rt, rd)
  end

  def test_mthi
    rs = 10
    assert_equal rs<<21 | 0x11, @_.mthi(rs)
  end

  def test_mtlo
    rs = 10
    assert_equal rs<<21 | 0x13, @_.mtlo(rs)
  end

  def test_mult
    rs = 10; rt = 20
    assert_equal rs<<21 | rt<<16 | 0x18, @_.mult(rs, rt)
  end

  def test_multu
    rs = 10; rt = 20
    assert_equal rs<<21 | rt<<16 | 0x19, @_.multu(rs, rt)
  end

  def test_nor
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x27, @_.nor(rd, rs, rt)
  end

  def test_or
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x25, @_.or(rd, rs, rt)
  end

  def test_ori
    rt = 10; rs = 20; imm = 30
    assert_equal 0x0d<<26 | rs<<21 | rt<<16 | imm, @_.ori(rt, rs, imm)
  end

  def test_sb
    rt = 10; offset = 20; base = 30
    assert_equal 0x28<<26 | base<<21 | rt<<16 | offset, @_.sb(rt, offset, base)
  end

  def test_sb_negative_offset
    rt = 10; offset = -20; base = 30
    assert_equal 0x28<<26 | base<<21 | rt<<16 | 0x10000+offset, @_.sb(rt, offset, base)
  end

  def test_sc
    rt = 10; offset = 20; base = 30
    assert_equal 0x38<<26 | base<<21 | rt<<16 | offset, @_.sc(rt, offset, base)
  end

  def test_sc_negative_offset
    rt = 10; offset = -20; base = 30
    assert_equal 0x38<<26 | base<<21 | rt<<16 | 0x10000+offset, @_.sc(rt, offset, base)
  end

  def test_scd
    rt = 10; offset = 20; base = 30
    assert_equal 0x3c<<26 | base<<21 | rt<<16 | offset, @_.scd(rt, offset, base)
  end

  def test_scd_negative_offset
    rt = 10; offset = -20; base = 30
    assert_equal 0x3c<<26 | base<<21 | rt<<16 | 0x10000+offset, @_.scd(rt, offset, base)
  end

  def test_sd
    rt = 10; offset = 20; base = 30
    assert_equal 0x3f<<26 | base<<21 | rt<<16 | offset, @_.sd(rt, offset, base)
  end

  def test_sd_negative_offset
    rt = 10; offset = -20; base = 30
    assert_equal 0x3f<<26 | base<<21 | rt<<16 | 0x10000+offset, @_.sd(rt, offset, base)
  end

  def test_sdc1
    rt = 10; offset = 20; base = 30
    assert_equal 0x3d<<26 | base<<21 | rt<<16 | offset, @_.sdc1(rt, offset, base)
  end

  def test_sdc1_negative_offset
    rt = 10; offset = -20; base = 30
    assert_equal 0x3d<<26 | base<<21 | rt<<16 | 0x10000+offset, @_.sdc1(rt, offset, base)
  end

  def test_sdl
    rt = 10; offset = 20; base = 30
    assert_equal 0x2c<<26 | base<<21 | rt<<16 | offset, @_.sdl(rt, offset, base)
  end

  def test_sdl_negative_offset
    rt = 10; offset = -20; base = 30
    assert_equal 0x2c<<26 | base<<21 | rt<<16 | 0x10000+offset, @_.sdl(rt, offset, base)
  end

  def test_sdr
    rt = 10; offset = 20; base = 30
    assert_equal 0x2d<<26 | base<<21 | rt<<16 | offset, @_.sdr(rt, offset, base)
  end

  def test_sdr_negative_offset
    rt = 10; offset = -20; base = 30
    assert_equal 0x2d<<26 | base<<21 | rt<<16 | 0x10000+offset, @_.sdr(rt, offset, base)
  end

  def test_sh
    rt = 10; offset = 20; base = 30
    assert_equal 0x29<<26 | base<<21 | rt<<16 | offset, @_.sh(rt, offset, base)
  end

  def test_sh_negative_offset
    rt = 10; offset = -20; base = 30
    assert_equal 0x29<<26 | base<<21 | rt<<16 | 0x10000+offset, @_.sh(rt, offset, base)
  end

  def test_sll
    rd = 10; rt = 20; sa = 30
    assert_equal rt<<16 | rd<<11 | sa<<6, @_.sll(rd, rt, sa)
  end

  def test_sllv
    rd = 10; rt = 20; rs = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x04, @_.sllv(rd, rt, rs)
  end

  def test_slt
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x2a, @_.slt(rd, rs, rt)
  end

  def test_slti
    rt = 10; rs = 20; imm = 30
    assert_equal 0x0a<<26 | rs<<21 | rt<<16 | imm, @_.slti(rt, rs, imm)
  end

  def test_slti_negative_immediate
    rt = 10; rs = 20; imm = -30
    assert_equal 0x0a<<26 | rs<<21 | rt<<16 | 0x10000+imm, @_.slti(rt, rs, imm)
  end

  def test_sltiu
    rt = 10; rs = 20; imm = 30
    assert_equal 0x0b<<26 | rs<<21 | rt<<16 | imm, @_.sltiu(rt, rs, imm)
  end

  def test_sltiu_negative_immediate
    rt = 10; rs = 20; imm = -30
    assert_equal 0x0b<<26 | rs<<21 | rt<<16 | 0x10000+imm, @_.sltiu(rt, rs, imm)
  end

  def test_sltu
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x2b, @_.sltu(rd, rs, rt)
  end

  def test_sra
    rd = 10; rt = 20; sa = 30
    assert_equal rt<<16 | rd<<11 | sa<<6 | 0x03, @_.sra(rd, rt, sa)
  end

  def test_srav
    rd = 10; rt = 20; rs = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x07, @_.srav(rd, rt, rs)
  end

  def test_srl
    rd = 10; rt = 20; sa = 30
    assert_equal rt<<16 | rd<<11 | sa<<6 | 0x02, @_.srl(rd, rt, sa)
  end

  def test_srlv
    rd = 10; rt = 20; rs = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x06, @_.srlv(rd, rt, rs)
  end

  def test_sub
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x22, @_.sub(rd, rs, rt)
  end

  def test_subu
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x23, @_.subu(rd, rs, rt)
  end

  def test_sw
    rt = 10; offset = 20; base = 30
    assert_equal 0x2b<<26 | base<<21 | rt<<16 | offset, @_.sw(rt, offset, base)
  end

  def test_swc1
    rt = 10; offset = 20; base = 30
    assert_equal 0x39<<26 | base<<21 | rt<<16 | offset, @_.swc1(rt, offset, base)
  end

  def test_swc2
    rt = 10; offset = 20; base = 30
    assert_equal 0x3a<<26 | base<<21 | rt<<16 | offset, @_.swc2(rt, offset, base)
  end

  def test_swl
    rt = 10; offset = 20; base = 30
    assert_equal 0x2a<<26 | base<<21 | rt<<16 | offset, @_.swl(rt, offset, base)
  end

  def test_swr
    rt = 10; offset = 20; base = 30
    assert_equal 0x2e<<26 | base<<21 | rt<<16 | offset, @_.swr(rt, offset, base)
  end

  def test_sync
    assert_equal 0x0f, @_.sync
  end

  def test_syscall
    code = 10
    assert_equal code<<6 | 0x0c, @_.syscall(code)
  end

  def test_teq
    rs = 10; rt = 20; code = 30
    assert_equal rs<<21 | rt<<16 | code<<6 | 0x34, @_.teq(rs, rt, code)
  end

  def test_teqi
    rs = 10; imm = 20
    assert_equal 0x01<<26 | rs<<21 | 0x0c<<16 | imm, @_.teqi(rs, imm)
  end

  def test_teqi_negative_immediate
    rs = 10; imm = -20
    assert_equal 0x01<<26 | rs<<21 | 0x0c<<16 | 0x10000+imm, @_.teqi(rs, imm)
  end

  def test_tge
    rs = 10; rt = 20; code = 30
    assert_equal rs<<21 | rt<<16 | code<<6 | 0x30, @_.tge(rs, rt, code)
  end

  def test_tgei
    rs = 10; imm = 20
    assert_equal 0x01<<26 | rs<<21 | 0x08<<16 | imm, @_.tgei(rs, imm)
  end

  def test_tgei_negative_immediate
    rs = 10; imm = -20
    assert_equal 0x01<<26 | rs<<21 | 0x08<<16 | 0x10000+imm, @_.tgei(rs, imm)
  end

  def test_tgeiu
    rs = 10; imm = 20
    assert_equal 0x01<<26 | rs<<21 | 0x09<<16 | imm, @_.tgeiu(rs, imm)
  end

  def test_tgeu
    rs = 10; rt = 20; code = 30
    assert_equal rs<<21 | rt<<16 | code<<6 | 0x31, @_.tgeu(rs, rt, code)
  end

  def test_tlbp
    assert_equal 0x10<<26 | 1<<25 | 0x08, @_.tlbp
  end

  def test_tlbr
    assert_equal 0x10<<26 | 1<<25 | 0x01, @_.tlbr
  end

  def test_tlbwi
    assert_equal 0x10<<26 | 1<<25 | 0x02, @_.tlbwi
  end

  def test_tlbwr
    assert_equal 0x10<<26 | 1<<25 | 0x06, @_.tlbwr
  end

  def test_tlt
    rs = 10; rt = 20; code = 30
    assert_equal rs<<21 | rt<<16 | code<<6 | 0x32, @_.tlt(rs, rt, code)
  end

  def test_tlti
    rs = 10; imm = 20
    assert_equal 0x01<<26 | rs<<21 | 0x0a<<16 | imm, @_.tlti(rs, imm)
  end

  def test_tlti_negative_immediate
    rs = 10; imm = -20
    assert_equal 0x01<<26 | rs<<21 | 0x0a<<16 | 0x10000+imm, @_.tlti(rs, imm)
  end

  def test_tltiu
    rs = 10; imm = 20
    assert_equal 0x01<<26 | rs<<21 | 0x0b<<16 | imm, @_.tltiu(rs, imm)
  end

  def test_tltu
    rs = 10; rt = 20; code = 30
    assert_equal rs<<21 | rt<<16 | code<<6 | 0x33, @_.tltu(rs, rt, code)
  end

  def test_tne
    rs = 10; rt = 20; code = 30
    assert_equal rs<<21 | rt<<16 | code<<6 | 0x36, @_.tne(rs, rt, code)
  end

  def test_tnei
    rs = 10; imm = 20
    assert_equal 0x01<<26 | rs<<21 | 0x0e<<16 | imm, @_.tnei(rs, imm)
  end

  def test_xor
    rd = 10; rs = 20; rt = 30
    assert_equal rs<<21 | rt<<16 | rd<<11 | 0x26, @_.xor(rd, rs, rt)
  end

  def test_xori
    rt = 10; rs = 20; imm = 30
    assert_equal 0x0e<<26 | rs<<21 | rt<<16 | imm, @_.xori(rt, rs, imm)
  end

  define_method :'test_abs.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x5, @_.abs.s(fd, fs)
  end

  define_method :'test_abs.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x5, @_.abs.d(fd, fs)
  end

  define_method :'test_add.s' do
    fd = 10; fs = 20; ft = 30
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | fd<<6, @_.add.s(fd, fs, ft)
  end

  define_method :'test_add.d' do
    fd = 10; fs = 20; ft = 30
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | fd<<6, @_.add.d(fd, fs, ft)
  end

  define_method :'test_c.f.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x30, @_.c.f.s(fs, ft)
  end

  define_method :'test_c.un.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x31, @_.c.un.s(fs, ft)
  end

  define_method :'test_c.eq.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x32, @_.c.eq.s(fs, ft)
  end

  define_method :'test_c.ueq.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x33, @_.c.ueq.s(fs, ft)
  end

  define_method :'test_c.olt.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x34, @_.c.olt.s(fs, ft)
  end

  define_method :'test_c.ult.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x35, @_.c.ult.s(fs, ft)
  end

  define_method :'test_c.ole.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x36, @_.c.ole.s(fs, ft)
  end

  define_method :'test_c.ule.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x37, @_.c.ule.s(fs, ft)
  end

  define_method :'test_c.sf.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x38, @_.c.sf.s(fs, ft)
  end

  define_method :'test_c.ngle.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x39, @_.c.ngle.s(fs, ft)
  end

  define_method :'test_c.seq.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x3a, @_.c.seq.s(fs, ft)
  end

  define_method :'test_c.ngl.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x3b, @_.c.ngl.s(fs, ft)
  end

  define_method :'test_c.lt.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x3c, @_.c.lt.s(fs, ft)
  end

  define_method :'test_c.nge.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x3d, @_.c.nge.s(fs, ft)
  end

  define_method :'test_c.le.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x3e, @_.c.le.s(fs, ft)
  end

  define_method :'test_c.ngt.s' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | 0x3f, @_.c.ngt.s(fs, ft)
  end

  define_method :'test_c.f.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x30, @_.c.f.d(fs, ft)
  end

  define_method :'test_c.un.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x31, @_.c.un.d(fs, ft)
  end

  define_method :'test_c.eq.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x32, @_.c.eq.d(fs, ft)
  end

  define_method :'test_c.ueq.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x33, @_.c.ueq.d(fs, ft)
  end

  define_method :'test_c.olt.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x34, @_.c.olt.d(fs, ft)
  end

  define_method :'test_c.ult.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x35, @_.c.ult.d(fs, ft)
  end

  define_method :'test_c.ole.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x36, @_.c.ole.d(fs, ft)
  end

  define_method :'test_c.ule.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x37, @_.c.ule.d(fs, ft)
  end

  define_method :'test_c.sf.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x38, @_.c.sf.d(fs, ft)
  end

  define_method :'test_c.ngle.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x39, @_.c.ngle.d(fs, ft)
  end

  define_method :'test_c.seq.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x3a, @_.c.seq.d(fs, ft)
  end

  define_method :'test_c.ngl.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x3b, @_.c.ngl.d(fs, ft)
  end

  define_method :'test_c.lt.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x3c, @_.c.lt.d(fs, ft)
  end

  define_method :'test_c.nge.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x3d, @_.c.nge.d(fs, ft)
  end

  define_method :'test_c.le.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x3e, @_.c.le.d(fs, ft)
  end

  define_method :'test_c.ngt.d' do
    fs = 10; ft = 20
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | 0x3f, @_.c.ngt.d(fs, ft)
  end

  define_method :'test_ceil.l.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x0a, @_.ceil.l.s(fd, fs)
  end

  define_method :'test_ceil.l.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x0a, @_.ceil.l.d(fd, fs)
  end

  define_method :'test_ceil.w.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x0e, @_.ceil.w.s(fd, fs)
  end

  define_method :'test_ceil.w.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x0e, @_.ceil.w.d(fd, fs)
  end

  define_method :'test_cvt.d.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x21, @_.cvt.d.s(fd, fs)
  end

  define_method :'test_cvt.d.w' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x14<<21 | fs<<11 | fd<<6 | 0x21, @_.cvt.d.w(fd, fs)
  end

  define_method :'test_cvt.d.l' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x15<<21 | fs<<11 | fd<<6 | 0x21, @_.cvt.d.l(fd, fs)
  end

  define_method :'test_cvt.l.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x25, @_.cvt.l.s(fd, fs)
  end

  define_method :'test_cvt.l.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x25, @_.cvt.l.d(fd, fs)
  end

  define_method :'test_cvt.s.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x20, @_.cvt.s.d(fd, fs)
  end

  define_method :'test_cvt.s.w' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x14<<21 | fs<<11 | fd<<6 | 0x20, @_.cvt.s.w(fd, fs)
  end

  define_method :'test_cvt.s.l' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x15<<21 | fs<<11 | fd<<6 | 0x20, @_.cvt.s.l(fd, fs)
  end

  define_method :'test_cvt.w.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x24, @_.cvt.w.s(fd, fs)
  end

  define_method :'test_cvt.w.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x24, @_.cvt.w.d(fd, fs)
  end

  define_method :'test_div.s' do
    fd = 10; fs = 20; ft = 30
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | fd<<6 | 0x03, @_.div.s(fd, fs, ft)
  end

  define_method :'test_div.d' do
    fd = 10; fs = 20; ft = 30
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | fd<<6 | 0x03, @_.div.d(fd, fs, ft)
  end

  define_method :'test_floor.l.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x0b, @_.floor.l.s(fd, fs)
  end

  define_method :'test_floor.l.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x0b, @_.floor.l.d(fd, fs)
  end

  define_method :'test_floor.w.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x0f, @_.floor.w.s(fd, fs)
  end

  define_method :'test_floor.w.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x0f, @_.floor.w.d(fd, fs)
  end

  define_method :'test_mov.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x06, @_.mov.s(fd, fs)
  end

  define_method :'test_mov.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x06, @_.mov.d(fd, fs)
  end

  define_method :'test_mul.s' do
    fd = 10; fs = 20; ft = 30
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | fd<<6 | 0x02, @_.mul.s(fd, fs, ft)
  end

  define_method :'test_mul.d' do
    fd = 10; fs = 20; ft = 30
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | fd<<6 | 0x02, @_.mul.d(fd, fs, ft)
  end

  define_method :'test_neg.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x07, @_.neg.s(fd, fs)
  end

  define_method :'test_neg.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x07, @_.neg.d(fd, fs)
  end

  define_method :'test_round.l.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x08, @_.round.l.s(fd, fs)
  end

  define_method :'test_round.l.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x08, @_.round.l.d(fd, fs)
  end

  define_method :'test_round.w.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x0c, @_.round.w.s(fd, fs)
  end

  define_method :'test_round.w.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x0c, @_.round.w.d(fd, fs)
  end

  define_method :'test_sqrt.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x04, @_.sqrt.s(fd, fs)
  end

  define_method :'test_sqrt.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x04, @_.sqrt.d(fd, fs)
  end

  define_method :'test_sub.s' do
    fd = 10; fs = 20; ft = 30
    assert_equal 0x11<<26 | 0x10<<21 | ft<<16 | fs<<11 | fd<<6 | 0x01, @_.sub.s(fd, fs, ft)
  end

  define_method :'test_sub.d' do
    fd = 10; fs = 20; ft = 30
    assert_equal 0x11<<26 | 0x11<<21 | ft<<16 | fs<<11 | fd<<6 | 0x01, @_.sub.d(fd, fs, ft)
  end

  define_method :'test_trunc.l.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x09, @_.trunc.l.s(fd, fs)
  end

  define_method :'test_trunc.l.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x09, @_.trunc.l.d(fd, fs)
  end

  define_method :'test_trunc.w.s' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x10<<21 | fs<<11 | fd<<6 | 0x0d, @_.trunc.w.s(fd, fs)
  end

  define_method :'test_trunc.w.d' do
    fd = 10; fs = 20
    assert_equal 0x11<<26 | 0x11<<21 | fs<<11 | fd<<6 | 0x0d, @_.trunc.w.d(fd, fs)
  end
end
end
