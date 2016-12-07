# frozen_string_literal: true
# -*- coding: binary -*-
module Rex
  module Post
    module Meterpreter
      module Extensions
        module Python
          TLV_TYPE_PYTHON_STDOUT = TLV_META_TYPE_STRING | (TLV_EXTENSIONS + 1)
          TLV_TYPE_PYTHON_STDERR             = TLV_META_TYPE_STRING | (TLV_EXTENSIONS + 2)
          TLV_TYPE_PYTHON_CODE               = TLV_META_TYPE_RAW    | (TLV_EXTENSIONS + 3)
          TLV_TYPE_PYTHON_CODE_LEN           = TLV_META_TYPE_UINT   | (TLV_EXTENSIONS + 4)
          TLV_TYPE_PYTHON_CODE_TYPE          = TLV_META_TYPE_UINT   | (TLV_EXTENSIONS + 5)
          TLV_TYPE_PYTHON_NAME               = TLV_META_TYPE_STRING | (TLV_EXTENSIONS + 6)
          TLV_TYPE_PYTHON_RESULT_VAR         = TLV_META_TYPE_STRING | (TLV_EXTENSIONS + 7)
          TLV_TYPE_PYTHON_RESULT             = TLV_META_TYPE_STRING | (TLV_EXTENSIONS + 8)
          end
      end
    end
  end
end
