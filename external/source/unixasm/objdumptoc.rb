#!/usr/bin/env ruby
# frozen_string_literal: true

class Parser
  SIZE1 = 28
  SIZE2 = 28 + 4 + 32
  SIZE3 = 28 + 4 + 32 + 4

  attr_accessor :file, :block, :block_size

  def initialize(filename)
    self.file = if filename.empty?
                  STDIN
                else
                  File.new(filename)
                end

    self.block = []
    self.block_size = 0
  end

  def block_begin(line)
    # Get the block name from label
    temp = line.scan(/\w+/)
    block_name = temp[1].delete('<>:')

    block << []
    block[-1] << "char #{block_name}[]="
  end

  def block_end
    # Insert the block size
    block[-1][0] = block[-1][0].ljust(SIZE1)
    block[-1][0] << '/*  '
    block[-1][0] << "#{block_size} bytes"
    block[-1][0] = block[-1][0].ljust(SIZE2)
    block[-1][0] << '  */'

    # Reset the block size
    self.block_size = 0

    block[-1] << ';'
    block[-1] << ''
  end

  def block_do(line)
    temp = line.split("\t")

    temp[1].strip!
    temp[1] = temp[1].scan(/\w+/)

    block[-1] << '    "'

    temp[1].each do |byte|
      block[-1][-1] << "\\x#{byte}"
      self.block_size += 1
    end

    block[-1][-1] << '"'
    block[-1][-1] = block[-1][-1].ljust(SIZE1)
    block[-1][-1] << '/*  '

    # For file format aixcoff-rs6000
    if temp.length == 4
      temp[2] << ' '
      temp[2] << temp[3]
      temp.pop
    end

    if temp.length == 3
      temp[2].strip!
      temp[2] = temp[2].scan(/[$%()+,\-\.<>\w]+/)

      if temp[2].length == 2
        block[-1][-1] << temp[2][0].ljust(8)
        block[-1][-1] << temp[2][1]
      elsif temp[2].length == 3
        block[-1][-1] << temp[2][0].ljust(8)
        block[-1][-1] << temp[2][1]
        block[-1][-1] << ' '
        block[-1][-1] << temp[2][2]
      else
        block[-1][-1] << temp[2].to_s
      end
    end

    block[-1][-1] = block[-1][-1].ljust(SIZE2)
    block[-1][-1] << '  */'
  end

  def parse_line(line)
    if line =~ /\w+ <[\.\w]+>:/
      # End a previous block
      block_end unless block_size == 0
      block_begin(line)

    elsif line =~ /\w+:\t/
      block_do(line)

    end
  end

  def parse_file(file)
    while (line = file.gets)
      parse_line(line)
    end

    # End the last block
    block_end unless block_size == 0
  end

  def parse
    parse_file(file)
  end

  def dump_all
    block.each do |block|
      block.each do |line|
        print "#{line}\n"
      end
    end
  end
end

if STDIN.tty?
  print "Tested with:\n"
  print "\tGNU objdump 2.9-aix51-020209\n"
  print "\tGNU objdump 2.15.92.0.2 20040927\n"
  print "Usage: objdump -dM suffix <file(s)> | ruby objdumptoc.rb\n"
else
  p = ::Parser.new('')
  p.parse
  p.dump_all
end
