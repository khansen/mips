Gem::Specification.new do |s|
  s.name        = 'mips'
  s.version     = '0.0.1'
  s.date        = '2012-11-30'
  s.summary     = "MIPS tools"
  s.description = "MIPS tools"
  s.authors     = ["Kent Hansen"]
  s.email       = 'kentmhan@gmail.com'
  s.files       = ['lib/mips.rb','lib/mips/assembler.rb','lib/mips/disassembler.rb','lib/mips/prepared_instruction.rb','lib/mips/type.rb','lib/mips/word_field.rb','test/mips/assembler_test.rb','test/mips/disassembler_test.rb']
  s.homepage    = 'http://rubygems.org/gems/mips'
  s.license     = 'MIT'
end
