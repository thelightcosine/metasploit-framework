# frozen_string_literal: true
##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::Remote::HttpClient
  include Msf::Auxiliary::Scanner

  def initialize(info = {})
    super(update_info(info,
                      'Name' => 'Apache HTTPD mod_negotiation Scanner',
                      'Description'	=> %q{
                          This module scans the webserver of the given host(s) for the existence of mod_negotiate.
                        If the webserver has mod_negotiation enabled, the IP address will be displayed.
                      },
                      'Author' 		=> [ 'diablohorn [at] gmail.com' ],
                      'License'		=> MSF_LICENSE))

    register_options(
      [
        OptString.new('PATH', [ true, "The path to detect mod_negotiation", '/']),
        OptString.new('FILENAME', [true, "Filename to use as a test", 'index'])
      ], self.class
    )
  end

  def run_host(ip)
    ecode = nil
    emesg = nil

    tpath = datastore['PATH']
    tfile = datastore['FILENAME']

    tpath += '/' if tpath[-1, 1] != '/'

    vhost = datastore['VHOST'] || ip
    prot  = datastore['SSL'] ? 'https' : 'http'

    #
    # Send the request and parse the response headers for an alternates header
    #
    begin
      # Send the request the accept header is key here
      res = send_request_cgi({
                               'uri' => tpath + tfile,
                               'method'   	=> 'GET',
                               'ctype'     => 'text/html',
                               'headers'	=> { 'Accept' => 'a/b' }
                             }, 20)

      return unless res

      # Sheck for alternates header
      print_status(ip.to_s) if res.code == 406

    rescue ::Rex::ConnectionRefused, ::Rex::HostUnreachable, ::Rex::ConnectionTimeout
    rescue ::Timeout::Error, ::Errno::EPIPE
    end
  end
end
