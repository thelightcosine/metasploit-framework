# frozen_string_literal: true
##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::Remote::Tcp

  include Msf::Auxiliary::Report
  include Msf::Auxiliary::Scanner

  def initialize
    super(
      'Name'        => 'TCP Port Scanner',
      'Description' => %q(
        Enumerate open TCP services by performing a full TCP connect on each port.
        This does not need administrative privileges on the source machine, which
        may be useful if pivoting.
      ),
      'Author'      => [ 'hdm', 'kris katterjohn' ],
      'License'     => MSF_LICENSE
    )

    register_options(
      [
        OptString.new('PORTS', [true, "Ports to scan (e.g. 22-25,80,110-900)", "1-10000"]),
        OptInt.new('TIMEOUT', [true, "The socket connect timeout in milliseconds", 1000]),
        OptInt.new('CONCURRENCY', [true, "The number of concurrent ports to check per host", 10]),
        OptInt.new('DELAY', [true, "The delay between connections, per thread, in milliseconds", 0]),
        OptInt.new('JITTER', [true, "The delay jitter factor (maximum value by which to +/- DELAY) in milliseconds.", 0])
      ], self.class
    )

    deregister_options('RPORT')
  end

  def run_host(ip)
    timeout = datastore['TIMEOUT'].to_i

    ports = Rex::Socket.portspec_crack(datastore['PORTS'])

    raise Msf::OptionValidateError, ['PORTS'] if ports.empty?

    jitter_value = datastore['JITTER'].to_i
    raise Msf::OptionValidateError, ['JITTER'] if jitter_value < 0

    delay_value = datastore['DELAY'].to_i
    raise Msf::OptionValidateError, ['DELAY'] if delay_value < 0

    until ports.empty?
      t = []
      r = []
      begin
        1.upto(datastore['CONCURRENCY']) do
          this_port = ports.shift
          break unless this_port
          t << framework.threads.spawn("Module(#{refname})-#{ip}:#{this_port}", false, this_port) do |port|
            begin

              # Add the delay based on JITTER and DELAY if needs be
              add_delay_jitter(delay_value, jitter_value)

              # Actually perform the TCP connection
              s = connect(false,
                          'RPORT' => port,
                          'RHOST' => ip,
                          'ConnectTimeout' => (timeout / 1000.0))
              print_status("#{ip}:#{port} - TCP OPEN")
              r << [ip, port, "open"]
            rescue ::Rex::ConnectionRefused
              vprint_status("#{ip}:#{port} - TCP closed")
              r << [ip, port, "closed"]
            rescue ::Rex::ConnectionError, ::IOError, ::Timeout::Error
            rescue ::Rex::Post::Meterpreter::RequestError
            rescue ::Interrupt
              raise $ERROR_INFO
            rescue ::Exception => e
              print_error("#{ip}:#{port} exception #{e.class} #{e} #{e.backtrace}")
            ensure
              begin
                disconnect(s)
              rescue
                nil
              end
            end
          end
        end
        t.each(&:join)

      rescue ::Timeout::Error
      ensure
        t.each do |x|
          begin
                      x.kill
                    rescue
                      nil
                    end
        end
      end

      r.each do |res|
        report_service(host: res[0], port: res[1], state: res[2])
      end
    end
  end
end
