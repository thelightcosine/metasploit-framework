# frozen_string_literal: true
# -*- coding: binary -*-

require 'msf/base/sessions/meterpreter'

module Msf
  module Sessions
    ###
    #
    # This class creates a platform-specific meterpreter session type
    #
    ###
    class Meterpreter_x86_Linux < Msf::Sessions::Meterpreter
      def initialize(rstream, opts = {})
        super
        self.base_platform = 'linux'
        self.base_arch = ARCH_X86
      end
    end
    end
end
