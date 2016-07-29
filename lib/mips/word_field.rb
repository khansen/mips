#
# Copyright (C) 2016 Kent Hansen
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
require 'mips/type'

module Mips
# A field of an instruction word.
# A field is defined by a type and a shift amount.
class WordField
  # The type of the field (Mips::Type).
  attr_reader :type
  # The shift amount (0 by default).
  attr_reader :shamt
  # Whether the field should be treated as a pointer (default false).
  attr_reader :is_pointer

  # Creates a field.
  def initialize(options)
    @type = Type[options.fetch(:type)]
    @shamt = options[:shamt] || 0
    raise "invalid shamt" if @shamt < 0 || @shamt+@type.width > 32
    @is_pointer = options[:is_pointer] || false
  end
  private :initialize

  # Returns the encoded (masked and shifted) form of the given +value+.
  def encode(value)
    raise "@type.fits?(value)" unless @type.fits?(value)
    (value << @shamt) & mask
  end

  # Returns the mask of this type.
  def mask; type.mask << @shamt; end

  # Sets this field of the given +word+ to the given +value+.
  def set(word, value); (word & ~mask) | encode(value); end

  # Gets this field of the given +word+.
  def get(word)
    raw_value = (word & mask) >> @shamt
    type.signed? && !type.fits?(raw_value) ? raw_value - (2 ** type.width) : raw_value
  end

  # Build all fields.
  [
    [:opcode, WordField.new(type: :opcode, shamt: 26)],
    [:funct,  WordField.new(type: :funct)],
    [:sa,     WordField.new(type: :sa, shamt: 6)],
    [:rd,     WordField.new(type: :gpr, shamt: 11)],
    [:rs,     WordField.new(type: :gpr, shamt: 21)],
    [:rt,     WordField.new(type: :gpr, shamt: 16)],
    [:cp0r,   WordField.new(type: :cp0r, shamt: 11)],
    [:fd,     WordField.new(type: :fpr, shamt: 6)],
    [:fs,     WordField.new(type: :fpr, shamt: 11)],
    [:ft,     WordField.new(type: :fpr, shamt: 16)],
    [:fmt,    WordField.new(type: :fmt, shamt: 21)],
    [:simm,   WordField.new(type: :simm)],
    [:uimm,   WordField.new(type: :uimm)],
    [:offset, WordField.new(type: :offset)],
    [:target, WordField.new(type: :target)],
    [:base,   WordField.new(type: :gpr, shamt: 21, is_pointer: true)],
    [:syscall_code, WordField.new(type: :syscall_code, shamt: 6)],
    [:trap_code, WordField.new(type: :trap_code, shamt: 6)]
  ].each do |(name,field)|
    class_variable_set("@@field_#{name}", field)
  end

  # Returns the field that corresponds to the given +name+ (a Symbol).
  def self.[](name); class_variable_get("@@field_#{name}"); end
end

end
