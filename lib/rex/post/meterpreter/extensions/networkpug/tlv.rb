# frozen_string_literal: true
# -*- coding: binary -*-
module Rex
  module Post
    module Meterpreter
      module Extensions
        module NetworkPug
          TLV_TYPE_EXTENSION_NETWORKPUG	= 0
          TLV_TYPE_NETWORKPUG_INTERFACE	= TLV_META_TYPE_STRING | (TLV_TYPE_EXTENSION_NETWORKPUG + TLV_EXTENSIONS + 1)
          TLV_TYPE_NETWORKPUG_FILTER	= TLV_META_TYPE_STRING | (TLV_TYPE_EXTENSION_NETWORKPUG + TLV_EXTENSIONS + 2)
          end
      end
    end
  end
end
