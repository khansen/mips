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
require 'mips/prepared_instruction'

module Mips
# The disassembler disassembles instructions.
#   require 'mips/disassembler'
#   puts Mips::Disassembler.disassemble(0x10203040) # "0xffff8000400003c0: 10203040 beqz $at, 0xffff80004000c4c4"
#
# The disassemble method is a convenience method that returns a string
# representation of an instruction.
#
# The decode method returns an object that allows for properties of the
# instruction (mnemonic, operands) to be queried.
class Disassembler
  # Represents a decoded instruction. See Mips::Disassembler::decode.
  class DecodedInstruction

    # The original instruction (32-bit integer) value.
    attr_reader :raw

    # Converts this decoded instruction to a string.
    def to_s
      stringify
    end

    def stringify(vaddr = 0) #:nodoc:
      s = self.mnemonic.to_s
      operands = self.operands
      if operands.any?
        s << ' '
        for i in 0...operands.size
          field = WordField[operands[i].first]
          if field.is_pointer
            s << '('
          else
            s << ', ' if i > 0
          end
          value = operands[i].last
          s << case field.type
            when SymbolicType
              field.type.key(value).to_s
            when OffsetType
              '0x' + ((vaddr + 4 + (value << 2)) & 0xffffffffffffffff).to_s(16)
            when TargetType
              '0x' + (((vaddr + 4) & 0xfffffffff0000000) | (value << 2)).to_s(16)
            else
              (value < 0 ? '-' : '') + '0x' + value.abs.to_s(16)
            end
          s << ')' if field.is_pointer
        end
      end
      s
    end

    def self.from_instruction(inst) #:nodoc:
      new inst
    end

    # Helper to recursively decode the raw instruction.
    def table_entry_helper(table, key)
      entry = table[key][WordField[key].get(@raw)]
      return entry if entry.is_a?(Array)
      if entry.is_a?(Hash)
        entry.keys.each do |next_key|
          sub_entry = table_entry_helper(entry, next_key)
          return sub_entry if sub_entry.is_a?(Array)
        end
      end
      nil
    end
    private :table_entry_helper

    # Helper to decode the raw instruction.
    # Returns an array with two elements: A mnemonic and a
    # +PreparedInstruction+.
    def table_entry
      unless defined? @table_entry
        table = Disassembler.class_variable_get("@@decoding_table")
        @table_entry = table_entry_helper(table, :opcode).select do |(_,instr)|
          (@raw & ~instr.mask) == 0
        end.sort do |(_,instr1),(_,instr2)|
          instr1.operands.length <=> instr2.operands.length
        end.first
      end
      @table_entry
    end
    private :table_entry

    # Returns the mnemonic of this decoded instruction as a symbol (e.g., +:add+).
    def mnemonic
      table_entry.first
    end

    # Returns the operands of this decoded instruction as an array of (field
    # name symbol, value) tuples (e.g., [[:rd, 10], [:rs, 20], [:rt, 30]]).
    # The definition of a field can be obtained through the Mips::WordField
    # \[\] class method.
    def operands
      table_entry.last.operands.map{ |name| [name, WordField[name].get(@raw)] }
    end

    def operands_hash
      operands.inject({}){ |h,(k,v)| (h[k] = v) && h }
    end

    def initialize(inst) #:nodoc:
      raise "inst.is_a? Integer" unless inst.is_a?Integer
      @raw = inst
    end
    private :initialize
  end

  # Helper method to populate the decoding tables recursively.
  def self.populate_decoding_tables(name, instr)
    if instr.unbound_fields.any?
      instr.first_unbound_field_alternatives.each_pair do |key,value|
        populate_decoding_tables("#{name}.#{key}", instr.bind_first_unbound_field(value))
      end
    else
      table = @@decoding_table
      instr.bound_fields[0...-1].each do |(field,value)|
        table[field] ||= {}
        table[field][value] ||= {}
        table = table[field][value]
      end
      last_field, last_value = instr.bound_fields.last
      table[last_field] ||= {}
      table[last_field][last_value] ||= []
      table[last_field][last_value] << [name.to_sym, instr]
    end
  end
  private_class_method :populate_decoding_tables

  # Build decoding tables from all known instructions.
  # The decoding tables are used to map a raw instruction (32-bit integer) to a
  # mnemonic (e.g., "cvt.d.s") and +PreparedInstruction+.
  @@decoding_table = {}
  PreparedInstruction.all.each do |(name,instr_array)|
    instr_array.each { |instr| populate_decoding_tables(name, instr) }
  end

  # Decodes the given instruction, +inst+ (a 32-bit integer), into a
  # Mips::Disassembler::DecodedInstruction instance. If a block is given,
  # the resulting DecodedInstruction is passed to the block, otherwise the
  # DecodedInstruction is returned.
  #
  #   Mips::Disassembler.decode(0x10203040) do |decoded|
  #     puts decoded.mnemonic.inspect # :bgtz
  #     puts decoded.operands.inspect # [[:rs, 1], [:offset, 12352]]
  #   end
  def self.decode(inst)
    decoded = DecodedInstruction.from_instruction(inst)
    begin
      decoded.mnemonic
    rescue
      raise "Invalid instruction."
    end
    block_given? ? yield(decoded) : decoded
  end

  # Disassembles the given instruction, +inst+.
  # Returns a string representation of the instruction.
  # The +options+ hash can be used to customize the output, and supports
  # the following keys:
  #
  # * +vaddr+: Virtual address of instruction
  def self.disassemble(inst, options = {})
    raise "inst.is_a? Integer" unless inst.is_a? Integer
    vaddr = options[:vaddr] || 0
    decoded = self.decode(inst) rescue nil
    '0x%.16x: %.8x %s' % [vaddr, inst, decoded ? decoded.stringify(vaddr) : '???']
#    '0x%.16x: %s' % [vaddr, decoded.stringify(vaddr)]
#    '%s' % decoded.stringify(vaddr)
  end

  def initialize #:nodoc:
    raise "Use Mips::Disassembler.disassemble instead."
  end
  private :initialize
end
end
