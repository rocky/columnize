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

  # When an option is not specified for the below keys, these
  # are the defaults.
  DEFAULT_OPTS = {
    :arrange_array     => false,
    :arrange_vertical  => true,
    :array_prefix      => '',
    :array_suffix      => '',
    :colfmt            => nil,
    :colsep            => '  ',
    :displaywidth      => 80,
    :lineprefix        => '',
    :linesuffix        => "\n",
    :ljust             => :auto,
    :term_adjust       => false
  }

  # Add +columnize_opts+ instance variable to classes that mix in this
  # module. The type should be a kind of hash as above.
  attr_accessor :columnize_opts  

  # Adds class variable into any class mixes in this module.
  def self.included(base)
    base.class_variable_set :@@columnize_opts, DEFAULT_OPTS.dup if 
      base.respond_to?(:class_variable_set)
  end

  module_function

  # Options parsing routine for Columnize::columnize. In the preferred
  # newer style, +args+ is either a hash where each key is one of the option
  # names: 
  #
  # 
  # In the older style positional arguments are used and the positions
  # are in the order: +displaywidth+, +colsep+, +arrange_vertical+,
  # +ljust+, and +lineprefix+.
  #
  # Thanks to ideas from Martin Davis, failing any explicit setting on
  # the columnize method call, we also now allow options to be picked
  # up from a columnize_opts instance variable or columnize_opts class
  # variable.
  def parse_columnize_options(args)
    list = args.shift

    if 1 == args.size && args[0].kind_of?(Hash)
      # Options were explicitly passed as a hash. Use that
      opts = DEFAULT_OPTS.merge(args[0])
      if opts[:arrange_array]
        opts[:array_prefix] = '['
        opts[:lineprefix]   = ' '
        opts[:linesuffix]   = ",\n"
        opts[:array_suffix] = "]\n"
        opts[:colsep]       = ', '
        opts[:arrange_vertical] = false
      end
      opts[:ljust] = !(list.all?{|datum| datum.kind_of?(Numeric)}) if 
        opts[:ljust] == :auto
      return list, opts
    elsif !args.empty?
      # Options were explicitly passes as ugly positional parameters.
      # Next priority
      opts = DEFAULT_OPTS.dup
      %w(displaywidth colsep arrange_vertical ljust lineprefix
        ).each do |field|
        break if args.empty?
        opts[field.to_sym] = args.shift
      end
    elsif defined?(@columnize_opts)
      # class has an option set as an instance variable.
      opts = @columnize_opts
    elsif defined?(@@columnize_opts)
      # class has an option set as a class variable.
      opts = @@columnize_opts.dup
    else
      # When all else fails, just use the default options.
      opts = DEFAULT_OPTS.dup
    end
    return list, opts
  end

  # Return the length of String +cell+. If Boolean +term_adjust+ is true,
  # ignore terminal sequences in +cell+.
  def cell_size(cell, term_adjust)
    if term_adjust
      cell.gsub(/\e\[.*?m/, '')
    else
      cell
    end.size
  end

  #   For example, for a line width of 4 characters (arranged vertically):
  #      a = (1..4).to_a
  #      Columnize.columnize(a) => '1  3\n2  4\n'
  #
  #   Alternatively: 
  #      a.columnize => '1  3\n2  4\n'
  #   
  #   Arranged horizontally:
  #      a.columnize(:arrange_vertical => false) => 
  #        ['1', '2,', '3', '4'] => '1  2\n3  4\n'
  # 
  #   Formatted as an array using format specifier '%02d':
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
    nrows = ncols = 0  # Make nrows, ncols have more global scope
    colwidths = []     # Same for colwidths
    if opts[:arrange_vertical]
      array_index = lambda {|num_rows, row, col| num_rows*col + row }
      # Try every row count from 1 upwards
      1.upto(l.size-1) do |_nrows|
        nrows = _nrows
        ncols = (l.size + nrows-1) / nrows
        colwidths = []
        totwidth = -opts[:colsep].length

        0.upto(ncols-1) do |col|
          # get max column width for this column
          colwidth = 0
          0.upto(nrows-1) do |_row|
            row = _row
            i = array_index.call(nrows, row, col)
            break if i >= l.size
            colwidth = [colwidth, cell_size(l[i], opts[:term_adjust])].max
          end
          colwidths.push(colwidth)
          totwidth += colwidth + opts[:colsep].length
          if totwidth > opts[:displaywidth]
            ncols = col
            break
          end
        end
        break if totwidth <= opts[:displaywidth]
      end
      ncols = 1 if ncols < 1
      nrows = l.size if ncols == 1
      # The smallest number of rows computed and the max widths for
      # each column has been obtained.  Now we just have to format
      # each of the rows.
      s = ''
      0.upto(nrows-1) do |_row| 
        row = _row
        texts = []
        0.upto(ncols-1) do |col|
          i = array_index.call(nrows, row, col)
          if i >= l.size
            x = ''
          else
            x = l[i]
          end
          texts.push(x)
        end
        texts.pop while !texts.empty? and texts[-1] == ''
        if texts.size > 0
          0.upto(texts.size-1) do |col|
            unless ncols == 1 && opts[:ljust]
              if opts[:ljust]
                texts[col] = texts[col].ljust(colwidths[col])
              else
                texts[col] = texts[col].rjust(colwidths[col])
              end
            end
          end
          s += "%s%s%s" % [opts[:lineprefix], texts.join(opts[:colsep]),
                           opts[:linesuffix]]
        end
      end
      return s
    else
      array_index = lambda {|ncols, row, col| ncols*(row-1) + col }
      # Assign to make enlarge scope of loop variables.
      totwidth = i = rounded_size = 0  
      # Try every column count from size downwards.
      l.size.downto(1) do |_ncols|
        ncols = _ncols
        # Try every row count from 1 upwards
        min_rows = (l.size+ncols-1) / ncols
        min_rows.upto(l.size) do |_nrows|
          nrows = _nrows
          rounded_size = nrows * ncols
          colwidths = []
          totwidth = -opts[:colsep].length
          colwidth = row = 0
          0.upto(ncols-1) do |col|
            # get max column width for this column
            1.upto(nrows) do |_row|
              row = _row
              i = array_index.call(ncols, row, col)
              break if i >= l.size
              colwidth = [colwidth, cell_size(l[i], opts[:term_adjust])].max
            end
            colwidths.push(colwidth)
            totwidth += colwidth + opts[:colsep].length
            break if totwidth > opts[:displaywidth];
          end
          if totwidth <= opts[:displaywidth]
            # Found the right nrows and ncols
            nrows  = row
            break
          elsif totwidth > opts[:displaywidth]
            # Need to reduce ncols
            break
          end
        end
        break if totwidth <= opts[:displaywidth] and i >= rounded_size-1
      end
      ncols = 1 if ncols < 1
      nrows = l.size if ncols == 1
      # The smallest number of rows computed and the max widths for
      # each column has been obtained.  Now we just have to format
      # each of the rows.
      s = ''
      prefix = if opts[:array_prefix].empty?
                 opts[:lineprefix] 
               else 
                 opts[:array_prefix]
               end
      1.upto(nrows) do |row| 
        texts = []
        0.upto(ncols-1) do |col|
          i = array_index.call(ncols, row, col)
          if i >= l.size
            break
          else
            x = l[i]
          end
          texts.push(x)
        end
        0.upto(texts.size-1) do |col|
          unless ncols == 1 && opts[:ljust]
            if opts[:ljust]
              texts[col] = texts[col].ljust(colwidths[col]) if ncols != 1
            else
              texts[col] = texts[col].rjust(colwidths[col])
            end
          end
        end
        s += "%s%s%s" % [prefix, texts.join(opts[:colsep]),
                         opts[:linesuffix]]
        prefix = opts[:lineprefix]
      end
      s += opts[:array_suffix]
      return s
    end
  end
end

# Mix in "Columnize" in the Array class and make the columnize method
# public.
## Array.send :include, Columnize
## Array.send :public, :columnize

class Array
  # returns data arranged in columns
  attr_accessor :columnize_opts
  def columnize(*args)
    if args.empty? and self.columnize_opts
      Columnize.columnize(self, self.columnize_opts)
    else
      Columnize.columnize(self, *args)
    end
  end
end


if __FILE__ == $0
  #
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
