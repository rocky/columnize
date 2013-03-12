# Copyright (C) 2007-2011, 2013 Rocky Bernstein
# <rockyb@rubyforge.net>
#
# Part of Columnize to format in the horizontal direction
module Columnize
  module_function
  def columnize_horizontal(list, opts)
    nrows, ncols, colwidths = compute_rows_cols_and_width list, opts
    justify = lambda {|t, c| opts[:ljust] ? t.ljust(colwidths[c]) : t.rjust(colwidths[c]) }
    # TODO: fix this logic
    prefix = opts[:array_prefix].empty? ? opts[:lineprefix] : opts[:array_prefix]
    (0...nrows).inject('') do |s, row|
      texts = list[row*ncols, ncols]
      texts.map!.with_index(&justify) unless ncols == 1 && opts[:ljust]
      s += "#{prefix}#{texts.join(opts[:colsep])}#{opts[:linesuffix]}"
      prefix = opts[:lineprefix]
      s
    end + opts[:array_suffix]
  end

  # compute the smallest number of rows and the max widths for each column
  def compute_rows_cols_and_width(list, opts)
    cell_widths = list.map {|x| cell_size(x, opts[:term_adjust]) }
    # default to 1 atom per row (just in case any atom > opts[:displaywidth])
    rcw = [list.length, 1, [cell_widths.max]]
    # return rcw if rcw[2][0] > opts[:displaywidth]

    # Try every column count from size downwards.
    list.size.downto(1) do |ncols|
      # given list.size and ncols, calculate minimum number of rows needed. this is very cool.
      nrows = (list.size + ncols - 1) / ncols
      colwidths = rows_and_cols(cell_widths, nrows, ncols)[1].map(&:max)
      totwidth = colwidths.inject(&:+) + ((ncols-1) * opts[:colsep].length)
      if totwidth <= opts[:displaywidth]
        rcw = [nrows, ncols, colwidths]
        break
      end
    end
    rcw
  end

  def rows_and_cols(list, nrows, ncols)
    rows = (0...nrows).map {|r| list[r*ncols, ncols] }
    cols = rows[0].zip(*rows[1..-1]).map(&:compact)
    [rows, cols]
  end
end
