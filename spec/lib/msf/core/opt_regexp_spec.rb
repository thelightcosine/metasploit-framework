# frozen_string_literal: true
# -*- coding:binary -*-

require 'spec_helper'
require 'msf/core/option_container'

RSpec.describe Msf::OptRegexp do
  valid_values = [
    { value: '^foo$', normalized: /^foo$/ }
  ]
  invalid_values = [
    { value: 123 },
    { value: 'foo(' }
  ]

  it_behaves_like "an option", valid_values, invalid_values, 'regexp'
end
