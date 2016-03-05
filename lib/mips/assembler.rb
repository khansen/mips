require 'mips/type'
require 'mips/word_field'
require 'mips/prepared_instruction'

module Mips
# The assembler assembles instructions.
#
#   require 'mips/assembler'
#   asm = Mips::Assembler.new
#   asm.add :$t0, $a0, $a1
#
# The org method sets the assembler's origin address.
#
# The label method defines a symbol that can be used as a target by control flow instructions.
#
# The push_instruction method appends a custom instruction word to this assembler's list of
# instructions.
#
# The instructions attribute contains the list of raw instruction words (32-bit integers).
class Assembler
  # The instructions assembled by this assembler, represented as raw 32-bit integers.
  attr_reader :instructions

  attr_reader :pc
  private :pc

  # Helper method for generated code.
  def assembler; self; end
  private :assembler

  # Creates a new assembler.
  def initialize
    @instructions = []
    @pc = 0
    @labels = {}
  end

  # Returns code that calculates the encoded form of the field with the given +name+.
  # Assumes the presence of a variable by the same name as the field
  # in the scope in which the generated code is executed.
  # Example output:
  #   rt<<16
  def self.compile_field_encoding(name)
    field = WordField[name]
    text = ''
    text << '(' if field.type.signed?
    text << name.to_s
    text << "&#{2 ** field.type.width - 1})" if field.type.signed?
    text << "<<#{field.shamt}" if field.shamt != 0
    text
  end
  private_class_method :compile_field_encoding

  # Returns code that calculates the final encoded form of an instruction from
  # the given immediate instruction, +instr+.
  # Assumes the presence of variables by the same names as the operands of the
  # instruction in the scope in which the generated code is executed.
  # Example output:
  #   0x14000000|rs<<21|rt<<16|(offset&65535)
  def self.compile_prepared_instruction(instr)
    raise 'Cannot compile partial instruction' if instr.partial?
    text = '0x' + instr.encode_bound_fields.to_s(16)
    instr.operands.each do |name|
      text << '|' << compile_field_encoding(name)
    end
    text
  end
  private_class_method :compile_prepared_instruction

  # Helper method for compile_assembler.
  # Returns code for a method called +name+ that assembles instructions from the
  # given immediate instruction, +instr+.
  # Example output (with indentation for improved readability):
  #   def add rd,rs,rt
  #     rd = WordField[:rd].type[rd] if rd.is_a?Symbol
  #     raise 'operand of invalid type' unless rd.is_a?Integer
  #     raise 'operand out of range' if rd<0||rd>31
  #     rs = WordField[:rs].type[rs] if rs.is_a?Symbol
  #     raise 'operand of invalid type' unless rs.is_a?Integer
  #     raise 'operand out of range' if rs<0||rs>31
  #     rt = WordField[:rt].type[rt] if rt.is_a?Symbol
  #     raise 'operand of invalid type' unless rt.is_a?Integer
  #     raise 'operand out of range' if rt<0||rt>31
  #     assembler.push_instruction(0x20|rd<<11|rs<<21|rt<<16)
  #   end
  def compile_immediate_assembler(name, instr)
    raise "instr.immediate?" unless instr.immediate?
    text = "def #{name}"
    operands = instr.operands
    if operands.any?
      # Add operand names to method signature
      text << ' ' << operands.map{ |oname| oname.to_s }.inject{ |memo,oname| memo + ',' + oname }
    end
    text << ';'

    # Convert/validate operands
    text << operands.map do |oname|
      field = WordField[oname]
      field.type.compile_conversion(oname)
    end.join

    # Encode and add instruction
    text << 'assembler.push_instruction(' << Assembler.send(:compile_prepared_instruction, instr) << ')'

    # eom
    text << ';end'
  end
  private :compile_immediate_assembler

  # Helper method for compile_assembler.
  # Returns code for a method called +name+ that assembles instructions from the
  # given partial instruction, +instr+.
  # The compiled method returns an object that has member methods that bind the
  # partial instruction's first unbound field. For example, the object generated
  # for the "ADD.fmt" instruction would have methods "s" and "d" that set the
  # resulting instruction word's "fmt" field accordingly.
  # Example output (with indentation for improved readability):
  #   def __add *args
  #     raise "instruction suffix expected" if args.any?
  #     @__add_handler||=Class.new do
  #       attr_reader :assembler
  #       def initialize(assembler)
  #         @assembler=assembler
  #       end
  #       def inspect
  #         '__add'
  #       end
  #       def s fd,fs,ft
  #         ... immediate assembler for add.s ...
  #       end
  #       def d fd,fs,ft
  #         ... immediate assembler for add.d ...
  #       end
  #     end.new assembler
  #   end
  def compile_partial_assembler(name, instr)
    raise "instr.partial?" unless instr.partial?
    text = "def #{name} *args;"
    text << 'raise "instruction suffix expected" if args.any?;'
    text << "@#{name}_handler||=Class.new do;"
    text << 'attr_reader :assembler;'
    text << 'def initialize(assembler);@assembler=assembler;end;'
    text << "def inspect;'#{name}';end"
    instr.first_unbound_field_alternatives.each_pair do |key,value|
      specialized_instr = instr.bind_first_unbound_field(value)
      text << ';' << compile_assembler(key, specialized_instr)
    end
    text << ";end.new assembler;"
    text << 'end'
  end
  private :compile_partial_assembler

  # Helper method for compile_assembler.
  # Returns code for a method called +name+ that assembles instructions from the
  # given instruction pair (+immed_instr+, +partial_instr+).
  # This is used to handle instructions that share a mnemonic prefix, but are
  # otherwise distinct instructions, such as "ADD" and "ADD.fmt".
  # Example output:
  #   def _add rd,rs,rt
  #     ... immediate assembler for add ...
  #   end
  #   private :_add
  #   def __add *args
  #     ... partial assembler for add.fmt ...
  #   end
  #   private :__add
  #   def add *args
  #     if args.any? then
  #       _add(*args) # Assume immediate
  #     else
  #       __add # Assume partial
  #     end
  #   end
  def compile_duplex_assembler(name, immed_instr, partial_instr)
    # Create helper method for immediate form.
    text = compile_immediate_assembler("_#{name}", immed_instr)
    text << ";private :_#{name};"

    # Create helper method for partial form.
    text << compile_partial_assembler("__#{name}", partial_instr)
    text << ";private :__#{name};"

    # Create the public method, which delegates to the appropriate helper.
    text << "def #{name} *args;"
    text << "if args.any? then _#{name}(*args) else __#{name} end;"
    text << 'end'
  end
  private :compile_duplex_assembler

  # Returns code for a method called +name+ that assembles instructions from the
  # given instruction descriptor, +descriptor+.
  def compile_assembler(name, descriptor)
    case descriptor
    when PreparedInstruction
      if descriptor.immediate?
        compile_immediate_assembler(name, descriptor)
      else
        compile_partial_assembler(name, descriptor)
      end
    when Array
      compile_duplex_assembler(name, *descriptor)
    end
  end
  private :compile_assembler

  # Implements lazy generation of instruction assemblers.
  def method_missing(name, *args, &block) #:nodoc:
    descriptor = PreparedInstruction.find_by_name(name)
    raise(NoMethodError, name.to_s) if descriptor.nil?

    text = compile_assembler(name, descriptor)
    puts text if $DEBUG

    # install the new method
    Assembler.class_eval text, __FILE__, 1

    # delegate to the new method
    send name, *args, &block
  end

  # Adds the given instruction, +instr+, to this assembler.
  def push_instruction(instr)
    assert "instr.is_a?(Integer)" unless instr.is_a?(Integer)
    self.instructions.push(instr)
    @pc += 1
    instr
  end

  # Sets the assembler's origin to the given +address+.
  def org(address)
    raise 'address.is_a?(Integer)' unless address.is_a?(Integer)
    raise 'address must be word-aligned' unless address & 3 == 0
    @pc = address>>2
  end

  # Defines a label named +sym+ (a Symbol).
  # The label can be used as a target in branch instructions. Example:
  #    j :foo
  #    ...
  #    label :foo
  #    addiu $t0, $t0, -1
  #    bnez $t0, :foo
  #    nop
  def label(sym)
    raise "sym.is_a?(Symbol)" unless sym.is_a?(Symbol)
    if @labels.key?(sym)
      lbl = @labels[sym]
      if lbl[:address]
        raise "Label '#{sym}' already defined" unless sym.is_a?(Symbol)
      else
        # Bind previously referenced label to current address.
        lbl[:address] = pc << 2
        lbl.delete(:refs).each do |ref|
          case @instructions[ref] >> 26
          when 2, 3 # J, JAL
            raise 'jump out of range' unless Type[:target].in_range?(ref+1, pc)
            @instructions[ref] = WordField[:target].set(@instructions[ref], pc & Type[:target].mask)
          else
            offset = pc - (ref + 1)
            raise 'operand out of range' unless Type[:offset].fits?(offset)
            @instructions[ref] = WordField[:offset].set(@instructions[ref], offset)
          end
        end
      end
    else
      # Bind previously unreferenced label to current address.
      @labels[sym] = { :address => pc << 2 }
    end
  end

  # Converts the given symbol, +sym+, to an address.
  # Registers the symbol as a label if it doesn't already exist.
  # If the label's address hasn't yet been bound, this method records the
  # current instruction's location to be backpatched later (see the +label+
  # method), and returns a placeholder value.
  def symbol_to_address(sym)
    raise 'sym.is_a?(Symbol)' unless sym.is_a?(Symbol)
    if @labels.key?(sym)
      lbl = @labels[sym]
      if lbl[:address]
        return lbl[:address]
      else
        lbl[:refs] << pc
      end
    else
      @labels[sym] = { :refs => [pc] }
    end
    (pc+1)<<2 # To be backpatched when the label is defined
  end
  private :symbol_to_address

  def symbol_to_offset(sym); (symbol_to_address(sym) - ((pc+1)<<2)) >> 2; end
  private :symbol_to_offset

  # Saves this assembler's instructions to a file with the given name,
  # +filename+.
  def save_instructions(filename, options = {})
    File.open(filename, "wb") do |f|
      f.write(instructions.pack("L>" * instructions.length))
    end
  end

  class << self
    # Creates global variables +$zero+, +$at+, +$v0+ etc. with the integer
    # value of the corresponding general purpose register (0..31).
    def install_global_gpr_symbols
      Type[:gpr].mapping.each_pair do |key,value|
        eval "#{key} = #{value}"
      end
    end
    # Creates global variables +$f0+, +$f1+, +$f2+ etc. with the integer
    # value of the corresponding floating point register (0..31).
    def install_global_fpr_symbols
      Type[:fpr].mapping.each_pair do |key,value|
        eval "#{key} = #{value}"
      end
    end
  end
end
end
