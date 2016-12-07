# frozen_string_literal: true
##
# WARNING: Metasploit no longer maintains or accepts meterpreter scripts.
# If you'd like to imporve this script, please try to port it as a post
# module instead. Thank you.
##

# Meterpreter script for detecting if target host is a Virtual Machine
# Provided by Carlos Perez at carlos_perez[at]darkoperator.com
# Version: 0.2.0
session = client

@@exec_opts = Rex::Parser::Arguments.new(
  "-h" => [ false, "Help menu." ]
)

@@exec_opts.parse(args) do |opt, _idx, _val|
  case opt
  when "-h"
    print_line("CheckVM -- Check various attributes on the target for evidence that it is a virtual machine")
    print_line("USAGE: run checkvm")
    print_line(@@exec_opts.usage)
    raise Rex::Script::Completed
  end
end

# Function for detecting if it is a Hyper-V VM
def hypervchk(session)
  begin
    vm = false
    key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft', KEY_READ)
    sfmsvals = key.enum_key
    if sfmsvals.include?("Hyper-V")
      print_status("This is a Hyper-V Virtual Machine")
      vm = true
    elsif sfmsvals.include?("VirtualMachine")
      print_status("This is a Hyper-V Virtual Machine")
      vm = true
    end
    key.close
  rescue
  end

  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SYSTEM\ControlSet001\Services', KEY_READ)
      srvvals = key.enum_key
      if srvvals.include?("vmicheartbeat")
        print_status("This is a Hyper-V Virtual Machine")
        vm = true
      elsif srvvals.include?("vmicvss")
        print_status("This is a Hyper-V Virtual Machine")
        vm = true
      elsif srvvals.include?("vmicshutdown")
        print_status("This is a Hyper-V Virtual Machine")
        vm = true
      elsif srvvals.include?("vmicexchange")
        print_status("This is a Hyper-V Virtual Machine")
        vm = true
      end
    rescue
    end
  end
  vm
end

# Function for checking if it is a VMware VM
def vmwarechk(session)
  vm = false
  begin
    key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SYSTEM\ControlSet001\Services', KEY_READ)
    srvvals = key.enum_key
    if srvvals.include?("vmdebug")
      print_status("This is a VMware Virtual Machine")
      vm = true
    elsif srvvals.include?("vmmouse")
      print_status("This is a VMware Virtual Machine")
      vm = true
    elsif srvvals.include?("VMTools")
      print_status("This is a VMware Virtual Machine")
      vm = true
    elsif srvvals.include?("VMMEMCTL")
      print_status("This is a VMware Virtual Machine")
      vm = true
    end
    key.close
  rescue
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0')
      if key.query_value('Identifier').data.downcase =~ /vmware/
        print_status("This is a VMware Virtual Machine")
        vm = true
      end
    rescue
    end
  end
  unless vm
    vmwareprocs = [
      "vmwareuser.exe",
      "vmwaretray.exe"
    ]
    vmwareprocs.each do |p|
      session.sys.process.get_processes.each do |x|
        if p == x['name'].downcase
          print_status("This is a VMware Virtual Machine") unless vm
          vm = true
        end
      end
    end
  end
  key.close
  vm
end

# Function for checking if it is a Virtual PC VM
def checkvrtlpc(session)
  vm = false
  vpcprocs = [
    "vmusrvc.exe",
    "vmsrvc.exe"
  ]
  vpcprocs.each do |p|
    session.sys.process.get_processes.each do |x|
      if p == x['name'].downcase
        print_status("This is a VirtualPC Virtual Machine") unless vm
        vm = true
      end
    end
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SYSTEM\ControlSet001\Services', KEY_READ)
      srvvals = key.enum_key
      if srvvals.include?("vpcbus")
        print_status("This is a VirtualPC Virtual Machine")
        vm = true
      elsif srvvals.include?("vpc-s3")
        print_status("This is a VirtualPC Virtual Machine")
        vm = true
      elsif srvvals.include?("vpcuhub")
        print_status("This is a VirtualPC Virtual Machine")
        vm = true
      elsif srvvals.include?("msvmmouf")
        print_status("This is a VirtualPC Virtual Machine")
        vm = true
      end
      key.close
    rescue
    end
  end
  vm
end

def vboxchk(session)
  vm = false
  vboxprocs = [
    "vboxservice.exe",
    "vboxtray.exe"
  ]
  vboxprocs.each do |p|
    session.sys.process.get_processes.each do |x|
      if p == x['name'].downcase
        print_status("This is a Sun VirtualBox Virtual Machine") unless vm
        vm = true
      end
    end
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\ACPI\DSDT', KEY_READ)
      srvvals = key.enum_key
      if srvvals.include?("VBOX__")
        print_status("This is a Sun VirtualBox Virtual Machine")
        vm = true
      end
    rescue
    end
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\ACPI\FADT', KEY_READ)
      srvvals = key.enum_key
      if srvvals.include?("VBOX__")
        print_status("This is a Sun VirtualBox Virtual Machine")
        vm = true
      end
    rescue
    end
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\ACPI\RSDT', KEY_READ)
      srvvals = key.enum_key
      if srvvals.include?("VBOX__")
        print_status("This is a Sun VirtualBox Virtual Machine")
        vm = true
      end
    rescue
    end
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0')
      if key.query_value('Identifier').data.downcase =~ /vbox/
        print_status("This is a Sun VirtualBox Virtual Machine")
        vm = true
      end
    rescue
    end
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\DESCRIPTION\System')
      if key.query_value('SystemBiosVersion').data.downcase =~ /vbox/
        print_status("This is a Sun VirtualBox Virtual Machine")
        vm = true
      end
    rescue
    end
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SYSTEM\ControlSet001\Services', KEY_READ)
      srvvals = key.enum_key
      if srvvals.include?("VBoxMouse")
        print_status("This is a Sun VirtualBox Virtual Machine")
        vm = true
      elsif srvvals.include?("VBoxGuest")
        print_status("This is a Sun VirtualBox Virtual Machine")
        vm = true
      elsif srvvals.include?("VBoxService")
        print_status("This is a Sun VirtualBox Virtual Machine")
        vm = true
      elsif srvvals.include?("VBoxSF")
        print_status("This is a Sun VirtualBox Virtual Machine")
        vm = true
      end
      key.close
    rescue
    end
  end
  vm
end

def xenchk(session)
  vm = false
  xenprocs = [
    "xenservice.exe"
  ]
  xenprocs.each do |p|
    session.sys.process.get_processes.each do |x|
      if p == x['name'].downcase
        print_status("This is a Xen Virtual Machine") unless vm
        vm = true
      end
    end
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\ACPI\DSDT', KEY_READ)
      srvvals = key.enum_key
      if srvvals.include?("Xen")
        print_status("This is a Xen Virtual Machine")
        vm = true
      end
    rescue
    end
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\ACPI\FADT', KEY_READ)
      srvvals = key.enum_key
      if srvvals.include?("Xen")
        print_status("This is a Xen Virtual Machine")
        vm = true
      end
    rescue
    end
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\ACPI\RSDT', KEY_READ)
      srvvals = key.enum_key
      if srvvals.include?("Xen")
        print_status("This is a Xen Virtual Machine")
        vm = true
      end
    rescue
    end
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SYSTEM\ControlSet001\Services', KEY_READ)
      srvvals = key.enum_key
      if srvvals.include?("xenevtchn")
        print_status("This is a Xen Virtual Machine")
        vm = true
      elsif srvvals.include?("xennet")
        print_status("This is a Xen Virtual Machine")
        vm = true
      elsif srvvals.include?("xennet6")
        print_status("This is a Xen Virtual Machine")
        vm = true
      elsif srvvals.include?("xensvc")
        print_status("This is a Xen Virtual Machine")
        vm = true
      elsif srvvals.include?("xenvdb")
        print_status("This is a Xen Virtual Machine")
        vm = true
      end
      key.close
    rescue
    end
  end
  vm
end

def qemuchk(session)
  vm = false
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0')
      if key.query_value('Identifier').data.downcase =~ /qemu/
        print_status("This is a QEMU/KVM Virtual Machine")
        vm = true
      end
    rescue
    end
  end
  unless vm
    begin
      key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\DESCRIPTION\System\CentralProcessor\0')
      if key.query_value('ProcessorNameString').data.downcase =~ /qemu/
        print_status("This is a QEMU/KVM Virtual Machine")
        vm = true
      end
    rescue
    end
  end

  vm
end

if client.platform =~ /win32|win64/
  print_status("Checking if target is a Virtual Machine .....")
  found = hypervchk(session)
  found = vmwarechk(session) unless found
  found = checkvrtlpc(session) unless found
  found = vboxchk(session) unless found
  found = xenchk(session) unless found
  found = qemuchk(session) unless found
  print_status("It appears to be physical host.") unless found
else
  print_error("This version of Meterpreter is not supported with this Script!")
  raise Rex::Script::Completed
end
