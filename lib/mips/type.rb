module Mips
# A type used in an instruction word. See Mips::WordField.
class Type
  # The width of the type, in bits.
  attr_reader :width
  # Whether the type is signed. The default is unsigned.
  def signed?; @signed; end

  # Creates a new type.
  def initialize(options)
    @width = options.fetch(:width)
    raise "invalid width" if @width < 0 || @width >= 32
    @signed = options[:signed] || false
  end
  private :initialize

  # Returns the bitmask for this type.
  def mask; 2 ** @width - 1; end

  # Returns the range of this type, represented as an
  # array [min, max].
  def range
    @signed ? [-(2 ** (@width-1)), 2 ** (@width-1) - 1] : [0, mask]
  end

  # Returns true if the given +value+ fits in this type, otherwise returns false.
  def fits?(value)
    min, max = range
    value >= min && value <= max
  end

  # Returns code for converting a variable to a value of this type.
  # The code will raise an error if conversion is not successful.
  def compile_conversion(name)
    text = "raise 'operand of invalid type' unless #{name}.is_a?Integer;"
    min, max = range
    text << "raise 'operand out of range' if #{name}<#{min}||#{name}>#{max};"
  end
end

# A symbolic type has a mapping from names (symbols) to values.
class SymbolicType < Type
  # The mapping from symbol to value, represented as a hash.
  attr_reader :mapping

  # Creates a symbolic type with the given +mapping+.
  def initialize(options)
    super
    @mapping = options.fetch(:mapping)
    raise "mapping.is_a?(Hash)" unless @mapping.is_a?(Hash)
  end
  private :initialize

  # Returns the value associated with the given +symbol+.
  def [](symbol); @mapping.fetch(symbol); end

  def key(value); @mapping.key(value); end

  # Returns code for converting a variable to a value of this type.
  # If the variable contains a symbol, it is overwritten with the
  # corresponding value.
  # The code will raise an error if conversion is not successful.
  def compile_conversion(name)
    text = "#{name} = WordField[:#{name}].type[#{name}] if #{name}.is_a?Symbol;"
    text + super(name)
  end
end

# The offset type is used in (relative) branch instructions.
class OffsetType < Type
  def initialize; super(width: 16, signed: true); end
  private :initialize

  # Returns code for converting a variable to a value of this type.
  # If the variable contains a symbol, it is interpreted as a label.
  # The code will raise an error if conversion is not successful.
  def compile_conversion(name)
    text = "#{name} = symbol_to_offset(#{name}) if #{name}.is_a?Symbol;"
    text + super
  end
end

# The target type is used in (absolute) jump instructions.
class TargetType < Type
  def initialize; super(width: 26); end
  private :initialize

  # Returns true if a jump from +from+ to +to+ is in range, otherwise returns false.
  def in_range?(from, to); (from ^ to) & ~mask == 0; end

  # Returns code for converting a variable to a value of this type.
  # If the variable contains a symbol, it is interpreted as a label.
  # The code will raise an error if conversion is not successful.
  def compile_conversion(name)
    text = "if #{name}.is_a?Symbol then #{name} = symbol_to_address(#{name}) elsif !#{name}.is_a?Integer then raise 'operand of invalid type' elsif #{name} & 3 != 0 then raise 'address must be word-aligned' end;"
    text << "raise 'jump out of range' unless Type[:target].in_range?(pc+1, #{name}>>2);"
    text << "#{name} = (#{name}>>2) & 0x#{mask.to_s(16)};"
  end
end

class Type
  # Build all types.
  [
    [:opcode, Type.new(width: 6)],
    [:funct,  Type.new(width: 6)],
    [:sa,     Type.new(width: 5)],
    [:gpr,    SymbolicType.new(width: 5,
                               mapping: {
                                 :$zero=>0, :$at=>1, :$v0=>2, :$v1=>3, :$a0=>4, :$a1=>5, :$a2=>6, :$a3=>7,
                                 :$t0=>8, :$t1=>9, :$t2=>10, :$t3=>11, :$t4=>12, :$t5=>13, :$t6=>14, :$t7=>15,
                                 :$s0=>16, :$s1=>17, :$s2=>18, :$s3=>19, :$s4=>20, :$s5=>21, :$s6=>22, :$s7=>23,
                                 :$t8=>24, :$t9=>25, :$k0=>26, :$k1=>27, :$gp=>28, :$sp=>29, :$s8=>30, :$ra=>31
                               })],
    [:cp0r,   SymbolicType.new(width: 5,
                               mapping: {
                                 Index:0, Random:1, EntryLo0:2, EntryLo1:3,
                                 Context:4, PageMask:5, Wired:6, BadVAddr:8,
                                 Count:9, EntryHi:10, Compare:11, SR:12,
                                 Cause:13, EPC:14, PRId:15, Config:16,
                                 LLAddr:17, WatchLo:18, WatchHi:19, XContext:20,
                                 ECC:26, CacheErr:27, TagLo:28, TagHi:29,
                                 ErrorEPC:30
                               })],
    [:fpr,    SymbolicType.new(width: 5, mapping: (0..31).inject({}) { |memo,i| memo["$f#{i}".to_sym] = i; memo })],
    [:fmt,    SymbolicType.new(width: 5, mapping: { :s => 16, :d => 17, :w => 20, :l => 21 })],
    [:simm,   Type.new(width: 16, signed: true)],
    [:uimm,   Type.new(width: 16)],
    [:offset, OffsetType.new],
    [:target, TargetType.new],
    [:syscall_code, Type.new(width: 20)],
    [:trap_code, Type.new(width: 10)]
  ].each do |(name,type)|
    class_variable_set("@@type_#{name}", type)
  end

  # Returns the type that corresponds to the given +name+ (a Symbol).
  def self.[](name); class_variable_get("@@type_#{name}"); end
end

end
