# frozen_string_literal: true
##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::ORACLE

  def initialize(info = {})
    super(update_info(info,
                      'Name'           => 'Oracle SQL Generic Query',
                      'Description'    => %q(
                          This module allows for simple SQL statements to be executed
                          against a Oracle instance given the appropriate credentials
                          and sid.
                      ),
                      'Author'         => [ 'MC' ],
                      'License'        => MSF_LICENSE,
                      'References'     =>
                        [
                          [ 'URL', 'https://www.metasploit.com/users/mc' ]
                        ],
                      'DisclosureDate' => 'Dec 7 2007'))

    register_options(
      [
        OptString.new('SQL', [ false, 'The SQL to execute.', 'select * from v$version'])
      ], self.class
    )
  end

  def run
    return unless check_dependencies

    query = datastore['SQL']

    begin
      print_status("Sending statement: '#{query}'...")
      result = prepare_exec(query)
      # Need this if statement because some statements won't return anything
      result&.each do |line|
        print_status(line)
      end
    rescue => e
      return
    end
  end
end
