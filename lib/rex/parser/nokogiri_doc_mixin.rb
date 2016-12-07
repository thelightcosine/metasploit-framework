# frozen_string_literal: true
# -*- coding: binary -*-
module Rex
  module Parser
    # Determines if Nokogiri is available and if it's a minimum
    # acceptable version.
    def self.load_nokogiri
      @nokogiri_loaded = false
      begin
        require 'nokogiri'
        major, minor = Nokogiri::VERSION.split(".")[0, 2]
        if major.to_i >= 1
          @nokogiri_loaded = true if minor.to_i >= 4
        end
      rescue LoadError => e
        @nokogiri_loaded = false
        @nokogiri_error  = e
      end
      @nokogiri_loaded
    end

    def self.nokogiri_loaded
      !!@nokogiri_loaded
    end

    # Useful during development, shouldn't be used in normal operation.
    def self.reload(fname)
      $stdout.puts "Reloading #{fname}..."
      load __FILE__
      load File.join(File.expand_path(File.dirname(__FILE__)), fname)
    end
  end
end

module Rex
  module Parser
    load_nokogiri && module NokogiriDocMixin
                       # Set up the getters and instance variables for the document
                       eval("attr_reader :args, :db, :state, :block, :report_data")

                       def initialize(args, db, &block)
                         @args = args
                         @db = db
                         @state = {}
                         @state[:current_tag] = {}
                         @block = block if block
                         @report_data = { wspace: args[:wspace] }
                         @nx_console_id = args[:nx_console_id]
                         super()
                       end

                       # Turn XML attribute pairs in to more workable hashes (there
                       # are better Enumerable tricks in Ruby 1.9, but ignoring for now)
                       def attr_hash(attrs)
                         h = {}
                         attrs.each { |k, v| h[k] = v }
                         h
                       end

                       def valid_ip(addr)
                         valid = false
                         valid = begin
                                 ::Rex::Socket::RangeWalker.new(addr).valid?
                               rescue
                                 false
                               end
                         !!valid
                       end

                       def normalize_ref(ref_type, ref_value)
                         return if ref_type.nil? || ref_type.empty? || ref_value.nil? || ref_value.empty?
                         ref_value = ref_value.strip
                         ref_type = ref_type.strip.upcase

                         ret = case ref_type
                               when "CVE"
                                 ref_value.gsub("CAN", "CVE")
                               when "MS"
                                 if ref_value =~ /^MS[0-9]/
                                   "MSB-#{ref_value}"
                                 else
                                   "MSB-MS#{ref_value}"
                                 end
                               when "URL", "BID"
                                 "#{ref_type}-#{ref_value}"
                               when "APPLE"
                                 ref_value
                               when "XF"
                                 if ref_value =~ /\((\d+)\)$/
                                   "#{ref_type}-#{Regexp.last_match(1)}"
                                 else
                                   "#{ref_type}-#{ref_value}"
                                 end
                               else # Handle others?
                                 "#{ref_type}-#{ref_value}"
                           end
                         ret
                       end

                       def normalize_references(orig_refs)
                         return [] unless orig_refs
                         refs = []
                         orig_refs.each do |ref_hash|
                           ref_hash_sym = Hash[ref_hash.map { |k, v| [k.to_sym, v] }]
                           ref_type = ref_hash_sym[:source].to_s.strip.upcase
                           ref_value = ref_hash_sym[:value].to_s.strip
                           refs << normalize_ref(ref_type, ref_value)
                         end
                         refs.compact.uniq
                       end

                       def in_tag(tagname)
                         @state[:current_tag].keys.include? tagname
                       end

                       # If there's an address, it's not on the blacklist,
                       # it has ports, and the port list isn't
                       # empty... it's okay.
                       def host_is_okay
                         return false unless @report_data[:host]
                         return false unless valid_ip(@report_data[:host])
                         return false unless @report_data[:state] == Msf::HostState::Alive
                         if @args[:blacklist]
                           return false if @args[:blacklist].include?(@report_data[:host])
                         end
                         return false unless @report_data[:ports]
                         return false if @report_data[:ports].empty?
                         true
                       end

                       # XXX: Document classes ought to define this
                       def determine_port_state(v)
                         v
                       end

                       # Circumvent the unknown attribute logging by the various reporters. They
                       # seem to be there just for debugging anyway.
                       def db_report(table, data)
                         raise "Data should be a hash" unless data.is_a? Hash
                         nonempty_data = data.reject { |_k, v| v.nil? }
                         valid_attrs = db_valid_attributes(table)
                         raise "Unknown table `#{table}'" if valid_attrs.empty?
                         case table
                         when :note, :web_site, :web_page, :web_form, :web_vuln
                           just_the_facts = nonempty_data
                         else
                           just_the_facts = nonempty_data.select { |k, _v| valid_attrs.include? k.to_s.to_sym }
                         end
                         return nil if just_the_facts.empty?
                         just_the_facts[:task] = @args[:task]
                         db.send("report_#{table}", just_the_facts)
                       end

                       # XXX: It would be better to either have a single registry of acceptable
                       # keys if we're going to alert on bad ones, or to be more forgiving if
                       # the caller is this thing. There is basically no way to tell if
                       # report_host()'s tastes are going to change with this scheme.
                       def db_valid_attributes(table)
                         case table.to_s.to_sym
                         when :host
                           ::Mdm::Host.new.attribute_names.map(&:to_sym) |
                             [:host, :workspace]
                         when :service
                           ::Mdm::Service.new.attribute_names.map(&:to_sym) |
                             [:host, :host_name, :mac, :workspace]
                         when :vuln
                           ::Mdm::Vuln.new.attribute_names.map(&:to_sym) |
                             [:host, :refs, :workspace, :port, :proto, :details, :exploited_at]
                         when :vuln_details
                           ::Mdm::VulnDetails.new.attribute_names.map(&:to_sym) | [ :key ]
                         when :host_details
                           ::Mdm::HostDetails.new.attribute_names.map(&:to_sym) | [ :key ]
                         when :note, :web_site, :web_page, :web_form, :web_vuln
                           # These guys don't complain
                           [:anything]
                         else
                           []
                         end
                       end

                       # Nokogiri 1.4.4 (and presumably beyond) generates attrs as pairs,
                       # like [["value1","foo"],["value2","bar"]] (but not hashes for some
                       # reason). 1.4.3.1 (and presumably 1.4.3.x and prior) generates attrs
                       # as a flat array of strings. We want array_pairs.
                       def normalize_attrs(attrs)
                         attr_pairs = []
                         case attrs.first
                         when Array, NilClass
                           attr_pairs = attrs
                         when String
                           attrs.each_index do |i|
                             next if i.even?
                             attr_pairs << [attrs[i - 1], attrs[i]]
                           end
                         else # Wow, yet another format! It's either from the distant past or distant future.
                           raise Msf::DBImportError, "Unknown format for XML attributes. Please check your Nokogiri version."
                         end
                         attr_pairs
                       end

                       # Removes HTML from a string
                       def strip_html_tags(text)
                         text.gsub!(/(<[^>]*>)|\n|\t/s) { " " }
                       end

                       # This breaks xml-encoded characters, so need to append.
                       # It's on the end_element tag name to turn the appending
                       # off and clear out the data.
                       def characters(text)
                         return unless @state[:has_text]
                         @text ||= ""
                         @text << text
                       end

                       # Effectively the same as characters()
                       def cdata_block(text)
                         return unless @state[:has_text]
                         @text ||= ""
                         @text << text
                       end

                       def end_document
                         block = @block
                         return unless @report_type_ok
                         unless @state[:current_tag].empty?
                           missing_ends = @state[:current_tag].keys.map { |x| "'#{x}'" }.join(", ")
                           msg = "Warning, the provided file is incomplete, and there may be missing\n"
                           msg << "data. The following tags were not closed: #{missing_ends}."
                           db.emit(:warning, msg, &block) if block
                         end
                       end
  end
    end
end
