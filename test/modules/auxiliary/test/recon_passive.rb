# frozen_string_literal: true
##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary
  include Msf::Auxiliary::Report
  include Msf::Exploit::Remote::Tcp

  def initialize
    super(
      'Name'        => 'Simple Recon Module Tester',
      'Description' => 'Simple Recon Module Tester',
      'Author'      => 'hdm',
      'License'     => MSF_LICENSE,
      'Actions'     =>
        [
          ['Continuous Port Sweep']
        ],
      'PassiveActions' =>
        [
          'Continuous Port Sweep'
        ]
    )

    register_options(
      [
        Opt::RHOST,
        Opt::RPORT
      ], self.class
    )
  end

  def run
    print_status("Running the simple recon module with action #{action.name}")

    case action.name
    when 'Continuous Port Sweep'
      loop do
        1.upto(65535) do |port|
          datastore['RPORT'] = port
          prober
        end
      end
    end
  end

  def prober
    connect
    disconnect
    report_host(host: datastore['RHOST'])
    report_service(
      host: datastore['RHOST'],
      port: datastore['RPORT'],
      proto: 'tcp'
    )
  rescue ::Exception => e
    case e.to_s
    when /connection was refused/
      report_host(host: datastore['RHOST'])
    else
      print_status(e.to_s)
    end
  end
end
