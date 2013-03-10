# Module to format an Array into a single string with embedded
# newlines, On printing the string, the columns are aligned.
#
# == Summary
#
#  Return a string from an array with embedded newlines formatted so
#  that when printed the columns are aligned.
#  See below for examples and options to the main method +columnize+.
#
#
# == License 
#
# Columnize is copyright (C) 2007-2011, 2013 Rocky Bernstein
# <rockyb@rubyforge.net>
#
# All rights reserved.  You can redistribute and/or modify it under
# the same terms as Ruby.
#
# Also available in Python (columnize), and Perl (Array::Columnize)

module Columnize

  # Pull in the rest of my pieces
  ROOT_DIR = File.dirname(__FILE__)
  %w(opts horizontal vertical version).each do |submod| 
    require File.join %W(#{ROOT_DIR} columnize #{submod})
  end

  module_function

  # Return the length of String +cell+. If Boolean +term_adjust+ is true,
  # ignore terminal sequences in +cell+.
  def cell_size(cell, term_adjust)
    if term_adjust
      cell.gsub(/\e\[.*?m/, '')
    else
      cell
    end.size
  end

  #  columize([args]) => String
  # 
  #  Return a string from an array with embedded newlines formatted so
  #  that when printed the columns are aligned.
  # 
  #  For example, for a line width of 4 characters (arranged vertically):
  #      a = (1..4).to_a
  #      Columnize.columnize(a) => '1  3\n2  4\n'
  #
  #  Alternatively: 
  #      a.columnize => '1  3\n2  4\n'
  #   
  #  Arranged horizontally:
  #      a.columnize(:arrange_vertical => false) => 
  #        ['1', '2,', '3', '4'] => '1  2\n3  4\n'
  # 
  #  Formatted as an array using format specifier '%02d':
  #      puts (1..10).to_a.columnize(:arrange_array => true, :colfmt => '%02d',
  #                                  :displaywidth => 10) =>
  #      [01, 02,
  #       03, 04,
  #       05, 06,
  #       07, 08,
  #       09, 10,
  #      ]
  #        
  # Each column is only as wide as necessary.  By default, columns are
  # separated by two spaces. Options are available for setting
  # * the line display width
  # * a column separator
  # * a line prefix
  # * a line suffix
  # * A format specify for formatting each item each array item to a string
  # * whether to ignore terminal codes in text size calculation
  # * whether to left justify text instead of right justify
  # * whether to format as an array - with surrounding [] and 
  #   separating ', '

  def columnize(*args)

    list, opts = parse_columnize_options(args)

    # Some degenerate cases
    return '' if not list.is_a?(Array)
    return  "<empty>\n" if list.empty?

    # Stringify array elements
    l = 
      if opts[:colfmt]
        list.map{|li| opts[:colfmt] % li}
      else
        list.map{|li| li.to_s}
      end

    return "%s%s%s\n" % [opts[:array_prefix], l[0], 
                         opts[:array_suffix]] if 1 == l.size

    if opts[:displaywidth] - opts[:lineprefix].length < 4
      opts[:displaywidth] = opts[:lineprefix].length + 4
    else
      opts[:displaywidth] -= opts[:lineprefix].length
    end
    if opts[:arrange_vertical]
      return columnize_vertical(l, opts)
    else
      return columnize_horizontal(l, opts)
    end
  end
end

# Mix in "Columnize" in the Array class and make the columnize method
# public.
# Array.send :include, Columnize
# Array.send :public, :columnize

class Array
  attr_accessor :columnize_opts
  def columnize(*args)
    if args.empty? and self.columnize_opts
      Columnize.columnize(self, self.columnize_opts)
    else
      Columnize.columnize(self, *args)
    end
  end
end

# Demo this sucker
if __FILE__ == $0
  include Columnize
  
  a = (1..80).to_a
  a.columnize_opts = {:arrange_array => true}
  puts a.columnize
  puts '=' * 50

  b = (1..10).to_a
  puts b.columnize(:displaywidth => 10)

  puts '-' * 50
  puts b.columnize(:arrange_array => true, :colfmt => '%02d',
                   :displaywidth => 10)

  line = 'require [1;29m"[0m[1;37mirb[0m[1;29m"[0m';
  puts cell_size(line, true);
  puts cell_size(line, false);

  [[4, 4], [4, 7], [100, 80]].each do |width, num|
    data = (1..num).map{|i| i}
    [[false, 'horizontal'], [true, 'vertical']].each do |bool, dir|
      puts "Width: #{width}, direction: #{dir}"
      print columnize(data, :displaywidth => width, :colsep => '  ', 
                      :arrange_vertical => bool, :ljust => :auto)
      end
  end

  puts Columnize::columnize(5)
  puts columnize([])
  puts columnize(["a", 2, "c"], :displaywidth =>10, :colsep => ', ')
  puts columnize(["oneitem"])
  puts columnize(["one", "two", "three"])
  data = ["one",       "two",         "three",
          "for",       "five",        "six",
          "seven",     "eight",       "nine",
          "ten",       "eleven",      "twelve",
          "thirteen",  "fourteen",    "fifteen",
          "sixteen",   "seventeen",   "eightteen",
          "nineteen",  "twenty",      "twentyone",
          "twentytwo", "twentythree", "twentyfour",
          "twentyfive","twentysix",   "twentyseven"]
  
  puts columnize(data)
  puts columnize(data, 80, '  ', false)

end
