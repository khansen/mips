require 'mips/type'
require 'mips/word_field'

module Mips
# A prepared instruction consists of
# * One or more bound fields (fields whose values are
# fixed; e.g, an opcode);
# * Zero or more unbound fields (fields whose values are
# determined by suffixes to the mnemonic); and
# * Zero or more operands (such as rs, rt).
class PreparedInstruction
  # The bound fields. There must be at least one (the major opcode).
  # Each item is a (symbol,value) pair.
  attr_reader :bound_fields
  # The unbound fields, or an empty array if there are no unbound fields.
  # Each item is a (field,alternatives) pair.
  attr_reader :unbound_fields
  # The operands, or an empty array if the instruction takes no operands.
  # Each item is a field name (a symbol).
  attr_reader :operands

  # Creates a prepared instruction.
  def initialize(options)
    @bound_fields = options.fetch(:bound_fields)
    @unbound_fields = options[:unbound_fields] || []
    @operands = options[:operands] || []
  end

  # Returns the alternatives for the first unbound field,
  # represented as a hash.
  def first_unbound_field_alternatives
    @unbound_fields.first.last
  end

  # Binds the first unbound field to the given +value+.
  # Returns a new prepared instruction based on this one, where the newly
  # bound field has been added to bound_fields and removed from
  # unbound_fields.
  def bind_first_unbound_field(value)
    field = @unbound_fields.first.first
    PreparedInstruction.new(bound_fields: @bound_fields + [[field,value]], unbound_fields: @unbound_fields[1..-1], operands: @operands)
  end

  # Returns true if this prepared instruction has no unbound fields, otherwise returns false.
  def immediate?; @unbound_fields.empty?; end

  # Returns true if this prepared instruction has one or more unbound fields, otherwise returns false.
  def partial?; @unbound_fields.any?; end

  # Returns the mask of this prepared instruction.
  def mask
    (@bound_fields + @unbound_fields + @operands).map do |(field,_)|
      WordField[field].mask
    end.inject do |memo,field_mask|
      memo | field_mask
    end
  end

  # Returns the combined encoding of all bound fields.
  def encode_bound_fields
    @bound_fields.map do |(name,value)|
      WordField[name].encode(value)
    end.inject do |memo,encoded_value|
      memo | encoded_value
    end
  end
end

class PreparedInstruction
  def self.major_op(*args)
    opcode = args.shift
    PreparedInstruction.new(bound_fields: [[:opcode,opcode]], operands: args)
  end
  private_class_method :major_op

  def self.special_op(*args)
    funct = args.shift
    PreparedInstruction.new(bound_fields: [[:opcode,0x00],[:funct,funct]], operands: args)
  end
  private_class_method :special_op

  def self.regimm_op(*args)
    rt = args.shift
    PreparedInstruction.new(bound_fields: [[:opcode,0x01],[:rt,rt]], operands: args)
  end
  private_class_method :regimm_op

  def self.cpz_mem_op(*args)
    cp = args.shift
    rs = args.shift
    PreparedInstruction.new(bound_fields: [[:opcode,0x10|cp],[:rs,rs]], operands: args)
  end
  private_class_method :cpz_mem_op

  def self.cpz_branch_op(*args)
    cp = args.shift
    rt = args.shift
    PreparedInstruction.new(bound_fields: [[:opcode,0x10|cp],[:rs,0x08],[:rt,rt]], operands: args)
  end
  private_class_method :cpz_branch_op

  def self.cp0_funct_op(*args)
    funct = args.shift
    PreparedInstruction.new(bound_fields: [[:opcode,0x10],[:rs,0x10],[:funct,funct]], operands: args)
  end
  private_class_method :cp0_funct_op

  def self.float_op(*args)
    funct = args.shift
    PreparedInstruction.new(bound_fields: [[:opcode,0x11],[:funct,funct]], unbound_fields: [[:fmt,Type[:fmt].mapping.select{|key,_| [:s,:d].member?(key) }]], operands: args)
  end
  private_class_method :float_op

  def self.suffix_float_op(*args)
    alternatives = args.shift
    PreparedInstruction.new(bound_fields: [[:opcode,0x11]], unbound_fields: [[:funct,alternatives],[:fmt,Type[:fmt].mapping.select{|key,_| [:s,:d].member?(key) }]], operands: args)
  end
  private_class_method :suffix_float_op

  def self.duplex_op(immediate_instr, partial_instr)
    [immediate_instr, partial_instr]
  end
  private_class_method :duplex_op

  # Build all instructions.
  @@instructions = {
    :j      => major_op(0x02,:target),
    :jal    => major_op(0x03,:target),
    :beq    => major_op(0x04,:rs,:rt,:offset),
    :bne    => major_op(0x05,:rs,:rt,:offset),
    :blez   => major_op(0x06,:rs,:offset),
    :bgtz   => major_op(0x07,:rs,:offset),
    :addi   => major_op(0x08,:rt,:rs,:simm),
    :addiu  => major_op(0x09,:rt,:rs,:simm),
    :slti   => major_op(0x0a,:rt,:rs,:simm),
    :sltiu  => major_op(0x0b,:rt,:rs,:simm), # FIXME: sign-extend and treat as unsigned
    :andi   => major_op(0x0c,:rt,:rs,:uimm),
    :ori    => major_op(0x0d,:rt,:rs,:uimm),
    :xori   => major_op(0x0e,:rt,:rs,:uimm),
    :lui    => major_op(0x0f,:rt,:simm),
    :beql   => major_op(0x14,:rs,:rt,:offset),
    :bnel   => major_op(0x15,:rs,:rt,:offset),
    :blezl  => major_op(0x16,:rs,:offset),
    :bgtzl  => major_op(0x17,:rs,:offset),
    :daddi  => major_op(0x18,:rt,:rs,:simm),
    :daddiu => major_op(0x19,:rt,:rs,:simm),
    :ldl    => major_op(0x1a,:rt,:simm,:base),
    :ldr    => major_op(0x1b,:rt,:simm,:base),
    :lb     => major_op(0x20,:rt,:simm,:base),
    :lh     => major_op(0x21,:rt,:simm,:base),
    :lwl    => major_op(0x22,:rt,:simm,:base),
    :lw     => major_op(0x23,:rt,:simm,:base),
    :lbu    => major_op(0x24,:rt,:simm,:base),
    :lhu    => major_op(0x25,:rt,:simm,:base),
    :lwr    => major_op(0x26,:rt,:simm,:base),
    :lwu    => major_op(0x27,:rt,:simm,:base),
    :sb     => major_op(0x28,:rt,:simm,:base),
    :sh     => major_op(0x29,:rt,:simm,:base),
    :swl    => major_op(0x2a,:rt,:simm,:base),
    :sw     => major_op(0x2b,:rt,:simm,:base),
    :sdl    => major_op(0x2c,:rt,:simm,:base),
    :sdr    => major_op(0x2d,:rt,:simm,:base),
    :swr    => major_op(0x2e,:rt,:simm,:base),
    :cache  => major_op(0x2f,:rt,:simm,:base),
    :ll     => major_op(0x30,:rt,:simm,:base),
    :lwc1   => major_op(0x31,:ft,:simm,:base),
    :lwc2   => major_op(0x32,:rt,:simm,:base),
    :lld    => major_op(0x34,:rt,:simm,:base),
    :ldc1   => major_op(0x35,:ft,:simm,:base),
    :ldc2   => major_op(0x36,:rt,:simm,:base),
    :ld     => major_op(0x37,:rt,:simm,:base),
    :sc     => major_op(0x38,:rt,:simm,:base),
    :swc1   => major_op(0x39,:ft,:simm,:base),
    :swc2   => major_op(0x3a,:rt,:simm,:base),
    :scd    => major_op(0x3c,:rt,:simm,:base),
    :sdc1   => major_op(0x3d,:ft,:simm,:base),
    :sdc2   => major_op(0x3e,:rt,:simm,:base),
    :sd     => major_op(0x3f,:rt,:simm,:base),

    :sll    => special_op(0x00,:rd,:rt,:sa),
    :srl    => special_op(0x02,:rd,:rt,:sa),
    :sra    => special_op(0x03,:rd,:rt,:sa),
    :sllv   => special_op(0x04,:rd,:rt,:rs),
    :srlv   => special_op(0x06,:rd,:rt,:rs),
    :srav   => special_op(0x07,:rd,:rt,:rs),
    :jr     => special_op(0x08,:rs),
    :jalr   => special_op(0x09,:rd,:rs), # TODO: "JALR rs" form (rd=31)
    :syscall => special_op(0x0c,:syscall_code),
    :break  => special_op(0x0d,:syscall_code),
    :sync   => special_op(0x0f),
    :mfhi   => special_op(0x10,:rd),
    :mthi   => special_op(0x11,:rs),
    :mflo   => special_op(0x12,:rd),
    :mtlo   => special_op(0x13,:rs),
    :dsllv  => special_op(0x14,:rd,:rt,:rs),
    :dsrlv  => special_op(0x16,:rd,:rt,:rs),
    :dsrav  => special_op(0x17,:rd,:rt,:rs),
    :mult   => special_op(0x18,:rs,:rt),
    :multu  => special_op(0x19,:rs,:rt),
    :divu   => special_op(0x1b,:rs,:rt),
    :dmult  => special_op(0x1c,:rs,:rt),
    :dmultu => special_op(0x1d,:rs,:rt),
    :ddiv   => special_op(0x1e,:rs,:rt),
    :ddivu  => special_op(0x1f,:rs,:rt),
    :addu   => special_op(0x21,:rd,:rs,:rt),
    :subu   => special_op(0x23,:rd,:rs,:rt),
    :and    => special_op(0x24,:rd,:rs,:rt),
    :or     => special_op(0x25,:rd,:rs,:rt),
    :xor    => special_op(0x26,:rd,:rs,:rt),
    :nor    => special_op(0x27,:rd,:rs,:rt),
    :slt    => special_op(0x2a,:rd,:rs,:rt),
    :sltu   => special_op(0x2b,:rd,:rs,:rt),
    :dadd   => special_op(0x2c,:rd,:rs,:rt),
    :daddu  => special_op(0x2d,:rd,:rs,:rt),
    :dsub   => special_op(0x2e,:rd,:rs,:rt),
    :dsubu  => special_op(0x2f,:rd,:rs,:rt),
    :tge    => special_op(0x30,:rs,:rt,:trap_code),
    :tgeu   => special_op(0x31,:rs,:rt,:trap_code),
    :tlt    => special_op(0x32,:rs,:rt,:trap_code),
    :tltu   => special_op(0x33,:rs,:rt,:trap_code),
    :teq    => special_op(0x34,:rs,:rt,:trap_code),
    :tne    => special_op(0x36,:rs,:rt,:trap_code),
    :dsll   => special_op(0x38,:rd,:rt,:sa),
    :dsrl   => special_op(0x3a,:rd,:rt,:sa),
    :dsra   => special_op(0x3b,:rd,:rt,:sa),
    :dsll32 => special_op(0x3c,:rd,:rt,:sa),
    :dsrl32 => special_op(0x3e,:rd,:rt,:sa),
    :dsra32 => special_op(0x3f,:rd,:rt,:sa),

    :bltz   => regimm_op(0x00,:rs,:offset),
    :bgez   => regimm_op(0x01,:rs,:offset),
    :bltzl  => regimm_op(0x02,:rs,:offset),
    :bgezl  => regimm_op(0x03,:rs,:offset),
    :tgei   => regimm_op(0x08,:rs,:simm),
    :tgeiu  => regimm_op(0x09,:rs,:simm),
    :tlti   => regimm_op(0x0a,:rs,:simm),
    :tltiu  => regimm_op(0x0b,:rs,:simm),
    :teqi   => regimm_op(0x0c,:rs,:simm),
    :tnei   => regimm_op(0x0e,:rs,:simm),
    :bltzal => regimm_op(0x10,:rs,:offset),
    :bgezal => regimm_op(0x11,:rs,:offset),
    :bltzall => regimm_op(0x12,:rs,:offset),
    :bgezall => regimm_op(0x13,:rs,:offset),

    :move   => major_op(0x08,:rt,:rs), # addi rt, rs, 0
    :clear  => special_op(0x20,:rd), # add rd, r0, r0
    :nop    => special_op(0x00), # sll r0, r0, r0
    :not    => special_op(0x27,:rd,:rs), # nor rd, rs, r0
    :b      => major_op(0x04,:offset), # beq r0, r0, offset
    :bal    => regimm_op(0x11,:offset), # bgezal r0, offset
    :beqz   => major_op(0x04,:rs,:offset), #beq rs, r0, offset
    :bnez   => major_op(0x05,:rs,:offset), #bne rs, r0, offset

    :mfc0   => cpz_mem_op(0,0x00,:rt,:cp0r),
    :mfc1   => cpz_mem_op(1,0x00,:rt,:rd),
    :mfc2   => cpz_mem_op(2,0x00,:rt,:rd),
    :dmfc0  => cpz_mem_op(0,0x01,:rt,:cp0r),
    :mtc0   => cpz_mem_op(0,0x04,:rt,:cp0r),
    :mtc1   => cpz_mem_op(1,0x04,:rt,:rd),
    :mtc2   => cpz_mem_op(2,0x04,:rt,:rd),
    :dmtc0  => cpz_mem_op(0,0x05,:rt,:cp0r),

    :cfc1   => cpz_mem_op(1,0x02,:rt,:rd),
    :cfc2   => cpz_mem_op(2,0x02,:rt,:rd),
    :ctc1   => cpz_mem_op(1,0x06,:rt,:rd),
    :ctc2   => cpz_mem_op(2,0x06,:rt,:rd),

    :bc0f   => cpz_branch_op(0,0x00,:offset),
    :bc1f   => cpz_branch_op(1,0x00,:offset),
    :bc2f   => cpz_branch_op(2,0x00,:offset),
    :bc0t   => cpz_branch_op(0,0x01,:offset),
    :bc1t   => cpz_branch_op(1,0x01,:offset),
    :bc2t   => cpz_branch_op(2,0x01,:offset),
    :bc0fl  => cpz_branch_op(0,0x02,:offset),
    :bc1fl  => cpz_branch_op(1,0x02,:offset),
    :bc2fl  => cpz_branch_op(2,0x02,:offset),
    :bc0tl  => cpz_branch_op(0,0x03,:offset),
    :bc1tl  => cpz_branch_op(1,0x03,:offset),
    :bc2tl  => cpz_branch_op(2,0x03,:offset),

    :tlbr   => cp0_funct_op(0x01),
    :tlbwi  => cp0_funct_op(0x02),
    :tlbwr  => cp0_funct_op(0x06),
    :tlbp   => cp0_funct_op(0x08),
    :eret   => cp0_funct_op(0x18),

    :abs    => float_op(0x05,:fd,:fs),
    :mov    => float_op(0x06,:fd,:fs),
    :mul    => float_op(0x02,:fd,:fs,:ft),
    :neg    => float_op(0x07,:fd,:fs),
    :sqrt   => float_op(0x04,:fd,:fs),

    :add    => duplex_op( special_op(0x20,:rd,:rs,:rt), float_op(0x00,:fd,:fs,:ft) ),
    :div    => duplex_op( special_op(0x1a,:rs,:rt),     float_op(0x03,:fd,:fs,:ft) ),
    :sub    => duplex_op( special_op(0x22,:rd,:rs,:rt), float_op(0x01,:fd,:fs,:ft) ),

    :ceil   => suffix_float_op({l:0x0a,w:0x0e},:fd,:fs),
    :floor  => suffix_float_op({l:0x0b,w:0x0f},:fd,:fs),
    :round  => suffix_float_op({l:0x08,w:0x0c},:fd,:fs),
    :trunc  => suffix_float_op({l:0x09,w:0x0d},:fd,:fs),

    :c      => PreparedInstruction.new(bound_fields: [[:opcode,0x11]], unbound_fields: [[:funct,{f:0x30,un:0x31,eq:0x32,ueq:0x33,olt:0x34,ult:0x35,ole:0x36,ule:0x37,sf:0x38,ngle:0x39,seq:0x3a,ngl:0x3b,lt:0x3c,nge:0x3d,le:0x3e,ngt:0x3f}],[:fmt,Type[:fmt].mapping.select{|key,_| [:s,:d].member?(key) }]], operands: [:fs,:ft]),

    :cvt    => PreparedInstruction.new(bound_fields: [[:opcode,0x11]], unbound_fields: [[:funct,{d:0x21,l:0x25,s:0x20,w:0x24}],[:fmt,Type[:fmt].mapping]], operands: [:fd,:fs]) # FIXME: not all permutations OK
  }

  # Returns the prepared instruction with the given +name+, or nil if not found.
  def self.find_by_name(name); @@instructions[name]; end

  def self.all; @@instructions.map { |key,value| [key,[value].flatten] }; end

end

end
