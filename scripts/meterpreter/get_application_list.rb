# frozen_string_literal: true
##
# WARNING: Metasploit no longer maintains or accepts meterpreter scripts.
# If you'd like to imporve this script, please try to port it as a post
# module instead. Thank you.
##

# Meterpreter script for listing installed applications and their version.
# Provided: carlos_perez[at]darkoperator[dot]com

# Options and Option Parsing
opts = Rex::Parser::Arguments.new(
  "-h" => [ false, "Help menu." ]
)

def app_list
  tbl = Rex::Text::Table.new(
    'Header'  => "Installed Applications",
    'Indent'  => 1,
    'Columns' => [
      "Name",
      "Version"
    ]
  )
  appkeys = ['HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall',
             'HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall' ]
  threadnum = 0
  a = []
  appkeys.each do |keyx86|
    soft_keys = registry_enumkeys(keyx86)
    soft_keys&.each do |k|
      if threadnum < 10
        a.push(::Thread.new do
                 begin
                   dispnm = registry_getvaldata("#{keyx86}\\#{k}", "DisplayName")
                   dispversion = registry_getvaldata("#{keyx86}\\#{k}", "DisplayVersion")
                   tbl << [dispnm, dispversion] if dispnm =~ /\S*/
                 rescue
                 end
               end)
        threadnum += 1
      else
        sleep(0.05) && a.delete_if { |x| !x.alive? } until a.empty?
        threadnum = 0
      end
    end
  end
  print_line("\n" + tbl.to_s + "\n")
end

opts.parse(args) do |opt, _idx, _val|
  case opt
  when "-h"
    print_line "Meterpreter Script for extracting a list installed applications and their version."
    print_line(opts.usage)
    raise Rex::Script::Completed

  end
end
if client.platform =~ /win32|win64/
  app_list
else
  print_error("This version of Meterpreter is not supported with this Script!")
  raise Rex::Script::Completed
end
