# frozen_string_literal: true
##
# nessus_xmlrpc_ping.rb
##

##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::Remote::HttpClient
  include Msf::Auxiliary::Report
  include Msf::Auxiliary::Scanner

  def initialize
    super(
      'Name'           => 'Nessus XMLRPC Interface Ping Utility',
      'Description'    => %q(
        This module simply attempts to find and check
        for Nessus XMLRPC interface.'
      ),
      'Author'         => [ 'Vlatko Kosturjak <kost[at]linux.hr>' ],
      'License'        => MSF_LICENSE,
      'DefaultOptions' => { 'SSL' => true }
    )

    register_options(
      [
        Opt::RPORT(8834),
        OptInt.new('THREADS', [true, "The number of concurrent threads", 25]),
        OptString.new('URI', [true, "URI for Nessus XMLRPC. Default is /", "/"])
      ], self.class
    )
  end

  def run_host(ip)
    begin
      res = send_request_cgi({
                               'uri' => datastore['URI'],
                               'method' => 'GET'
                             }, 25)
      http_fingerprint(response: res)
    rescue ::Rex::ConnectionError => e
      vprint_error("#{datastore['URI']} - #{e}")
      return
    end

    unless res
      vprint_error("#{datastore['URI']} - No response")
      return
    end
    unless (res.code == 200) || (res.code == 302)
      vprint_error("HTTP Response was not 200/302")
      return
    end
    if res.headers['Server'] =~ /NessusWWW/
      print_good("SUCCESS. '#{ip}' : '#{datastore['RPORT']}'")
      report_service(
        host: ip,
        port: datastore['RPORT'],
        name: "nessus-xmlrpc",
        info: 'Nessus XMLRPC',
        state: 'open'
      )
    else
      vprint_error("Wrong HTTP Server header: #{res.headers['Server'] || ''}")
    end
  end
end
