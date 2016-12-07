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
    class Meterpreter_mipsle_Linux < Msf::Sessions::Meterpreter
      def supports_ssl?
        false
      end

      def supports_zlib?
        false
      end

      def initialize(rstream, opts = {})
        super
        self.base_platform = 'linux'
        self.base_arch = ARCH_MIPSLE
      end
    end
  end
end
