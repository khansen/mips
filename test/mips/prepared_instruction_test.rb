require 'test/unit'
require 'mips'

module Mips
class PreparedInstructionTest < Test::Unit::TestCase #:nodoc:
  def test_immediate
    instr = PreparedInstruction.find_by_name(:xori)
    assert instr.immediate?
    assert_equal false, instr.partial?
    assert_equal [[:opcode,14]], instr.bound_fields
    assert_equal [], instr.unbound_fields
    assert_equal [:rt, :rs, :uimm], instr.operands
    assert_equal 0xffffffff, instr.mask
  end

  def test_partial
    instr = PreparedInstruction.find_by_name(:abs)
    assert instr.partial?
    assert_equal false, instr.immediate?
    assert_equal [[:opcode,17],[:funct,5]], instr.bound_fields
    assert_equal [[:fmt,{:s=>16,:d=>17}]], instr.unbound_fields
    assert_equal({:s=>16,:d=>17},instr.first_unbound_field_alternatives)
    assert_equal [:fd, :fs], instr.operands
    assert_equal 0xffe0ffff, instr.mask
  end

  def test_bind
    instr = PreparedInstruction.find_by_name(:abs).bind_first_unbound_field(16)
    assert instr.immediate?
    assert_equal false, instr.partial?
    assert_equal [[:opcode,17],[:funct,5],[:fmt,16]], instr.bound_fields
    assert_equal [], instr.unbound_fields
    assert_equal [:fd, :fs], instr.operands
    assert_equal 0xffe0ffff, instr.mask
  end
end
end
