# frozen_string_literal: true
# -*- coding: binary -*-
module Rex
  module Post
    module Meterpreter
      module Extensions
        module Powershell
          TLV_TYPE_POWERSHELL_SESSIONID = TLV_META_TYPE_STRING | (TLV_EXTENSIONS + 1)
          TLV_TYPE_POWERSHELL_CODE             = TLV_META_TYPE_STRING | (TLV_EXTENSIONS + 2)
          TLV_TYPE_POWERSHELL_RESULT           = TLV_META_TYPE_STRING | (TLV_EXTENSIONS + 3)
          TLV_TYPE_POWERSHELL_ASSEMBLY_SIZE    = TLV_META_TYPE_UINT   | (TLV_EXTENSIONS + 4)
          TLV_TYPE_POWERSHELL_ASSEMBLY         = TLV_META_TYPE_RAW    | (TLV_EXTENSIONS + 5)
          end
      end
    end
  end
end
