# frozen_string_literal: true
require 'rex/parser/openvas_nokogiri'

module Msf::DBManager::Import::OpenVAS
  def import_openvas_new_xml(args = {}, &block)
    doc = if block
            Rex::Parser::OpenVASDocument.new(args, framework.db) { |type, data| yield type, data }
          else
            Rex::Parser::OpenVASDocument.new(args, self)
          end
    parser = ::Nokogiri::XML::SAX::Parser.new(doc)
    parser.parse(args[:data])
  end

  def import_openvas_new_xml_file(args = {})
    filename = args[:filename]
    wspace = args[:wspace] || workspace

    data = ""
    ::File.open(filename, 'rb') do |f|
      data = f.read(f.stat.size)
    end
    import_wapiti_xml(args.merge(data: data))
  end

  #
  # Of course they had to change the nessus format.
  #
  def import_openvas_xml(args = {})
    filename = args[:filename]
    wspace = args[:wspace] || workspace

    raise Msf::DBImportError, "No OpenVas XML support. Please submit a patch to msfdev[at]metasploit.com"
  end
end
