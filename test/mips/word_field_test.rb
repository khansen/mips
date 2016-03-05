require 'test/unit'
require 'mips/type'
require 'mips/word_field'

module Mips
class WordFieldTest < Test::Unit::TestCase #:nodoc:
  def test_create
    type = Type[:gpr]
    field = WordField.new(:type => :gpr)
    assert_equal type, field.type
    assert_equal 0, field.shamt
  end

  def test_create_negative_shamt
    assert_raise RuntimeError do
      WordField.new(:type => :gpr, :shamt => -1)
    end
  end

  def test_create_too_big_shamt
    assert_raise RuntimeError do
      WordField.new(:type => :gpr, :shamt => 29)
    end
  end

  def test_create_with_shamt
    type = Type[:gpr]
    field = WordField.new(:type => :gpr, :shamt => 5)
    assert_equal type, field.type
    assert_equal 5, field.shamt
  end

  def test_mask
    type = Type[:gpr]
    field = WordField.new(:type => :gpr)
    assert_equal type.mask, field.mask
  end

  def test_mask_with_shamt
    type = Type[:gpr]
    field = WordField.new(:type => :gpr, :shamt => 5)
    assert_equal type.mask << 5, field.mask
  end

  def test_encode_unsigned_type
    field = WordField.new(:type => :gpr)
    assert_equal 19, field.encode(19)
  end

  def test_encode_unsigned_type_out_of_range
    field = WordField.new(:type => :gpr)
    assert_raise RuntimeError do
      field.encode(32)
    end
  end

  def test_encode_unsigned_type_negative_value
    field = WordField.new(:type => :gpr)
    assert_raise RuntimeError do
      field.encode(-1)
    end
  end

  def test_encode_signed_type
    field = WordField.new(:type => :offset)
    assert field.type.signed?
    assert_equal 19, field.encode(19)
  end

  def test_encode_signed_type_negative_value
    field = WordField.new(:type => :offset)
    assert_equal 0xffed, field.encode(-19)
  end

  def test_encode_signed_type_negative_value_out_of_range
    field = WordField.new(:type => :offset)
    assert_raise RuntimeError do
      field.encode(-0x9000)
    end
  end

  def test_encode_signed_type_positive_value_out_of_range
    field = WordField.new(:type => :offset)
    assert_raise RuntimeError do
      field.encode(0x9000)
    end
  end

  def test_encode_with_shamt
    field = WordField.new(:type => :gpr, :shamt => 5)
    assert_equal 19 << 5, field.encode(19)
  end

  def test_encode_signed_type_with_shamt
    field = WordField.new(:type => :offset, :shamt => 5)
    assert_equal 0xffed << 5, field.encode(-19)
  end

  def test_get
    field = WordField.new(:type => :gpr)
    assert_equal 19, field.get(0xfffffff3)
  end

  def test_get_with_shamt
    field = WordField.new(:type => :gpr, :shamt => 5)
    assert_equal 19, field.get(0xfffffe7f)
  end

  def test_set
    field = WordField.new(:type => :gpr)
    assert_equal 0xfffffff3, field.set(0xffffffff, 19)
  end

  def test_set_with_shamt
    field = WordField.new(:type => :gpr, :shamt => 5)
    assert_equal 0xfffffe7f, field.set(0xffffffff, 19)
  end
end
end
