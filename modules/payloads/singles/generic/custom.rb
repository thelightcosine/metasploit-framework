# frozen_string_literal: true
##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'
require 'msf/core/payload/generic'

module MetasploitModule
  CachedSize = 0

  include Msf::Payload::Single
  include Msf::Payload::Generic

  def initialize(info = {})
    super(merge_info(info,
                     'Name'          => 'Custom Payload',
                     'Description'   => 'Use custom string or file as payload. Set either PAYLOADFILE or
                               PAYLOADSTR.',
                     'Author'        => 'scriptjunkie <scriptjunkie[at]scriptjunkie.us>',
                     'License'       => MSF_LICENSE,
                     'Payload'	    =>
                       {
                         'Payload' => "" # not really
                       }))

    # Register options
    register_options(
      [
        OptString.new('PAYLOADFILE', [ false, "The file to read the payload from" ]),
        OptString.new('PAYLOADSTR', [ false, "The string to use as a payload" ])
      ], self.class
    )
  end

  #
  # Construct the payload
  #
  def generate
    self.arch = actual_arch if datastore['ARCH']

    if datastore['PAYLOADFILE']
      IO.read(datastore['PAYLOADFILE'])
    elsif datastore['PAYLOADSTR']
      datastore['PAYLOADSTR']
    end
  end

  # Only accept the "none" encoder
  def compatible_encoders
    encoders = super()
    encoders2 = []
    encoders.each do |encname, encmod|
      encoders2 << [encname, encmod] if encname.include? 'none'
    end

    encoders2
  end
end
