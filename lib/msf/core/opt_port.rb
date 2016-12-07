# frozen_string_literal: true
# -*- coding: binary -*-

module Msf
  ###
  #
  # Network port option.
  #
  ###
  class OptPort < OptInt
    def type
      'port'
    end

    def valid?(value, check_empty: true)
      port = normalize(value).to_i
      super && port <= 65535 && port >= 0
    end
  end
end
