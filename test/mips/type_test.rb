require 'test/unit'
require 'mips/type'

module Mips
class TypeTest < Test::Unit::TestCase #:nodoc:
  def test_create
    type = Type.new(:width => 5)
    assert_equal 5, type.width
    assert_equal false, type.signed?
  end

  def test_create_signed
    type = Type.new(:width => 5, :signed => true)
    assert_equal 5, type.width
    assert type.signed?
  end

  def test_mask
    type = Type.new(:width => 5)
    assert_equal 31, type.mask
  end

  def test_mask_signed
    type = Type.new(:width => 5, :signed => true)
    assert_equal 31, type.mask
  end

  def test_range
    type = Type.new(:width => 5)
    assert_equal [0, 31], type.range
  end

  def test_range_signed
    type = Type.new(:width => 5, :signed => true)
    assert_equal [-16, 15], type.range
  end

  def test_fits
    type = Type.new(:width => 5)
    assert type.fits?(19)
  end

  def test_fits_signed
    type = Type.new(:width => 5, :signed => true)
    assert type.fits?(-13)
  end

  def test_fits_unsigned_out_of_range
    type = Type.new(:width => 5)
    assert_equal false, type.fits?(32)
  end
end
end
