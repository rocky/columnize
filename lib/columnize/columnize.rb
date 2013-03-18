# Copyright (C) 2007-2011, 2013 Rocky Bernstein
# <rockyb@rubyforge.net>
#
# Part of Columnize to format in either direction
module Columnize
  module_function
  def _columnize(list, opts)
    rows, colwidths = compute_rows_and_colwidths list, opts
    ncols = colwidths.length
    justify = lambda {|t, c| opts[:ljust] ? t.ljust(colwidths[c]) : t.rjust(colwidths[c]) }
    textify = lambda do |s, row|
      row.map!.with_index(&justify) unless ncols == 1 && opts[:ljust]
      s + "#{opts[:lineprefix]}#{row.join(opts[:colsep])}#{opts[:linesuffix]}"
    end

    text = rows.inject('', &textify)
    text = text.sub(opts[:lineprefix], opts[:array_prefix]) + opts[:array_suffix] unless opts[:array_prefix].empty?
    text
  end

  # compute the smallest number of rows and the max widths for each column
  def compute_rows_and_colwidths(list, opts)
    cell_widths = list.map {|x| cell_size(x, opts[:term_adjust]) }
    # default is 1 atom per row (just in case any atom > opts[:displaywidth])
    rcw = [rows_and_cols(list, 1)[0], [cell_widths.max]]
    return rcw if rcw[1][0] > opts[:displaywidth]

    # TODO: explain why
    sizes, ri, ci = (1..list.length).to_a, 1, 0
    sizes, ri, ci = sizes.reverse, 0, 1 unless opts[:arrange_vertical]

    sizes.each do |size|
      colwidths = rows_and_cols(cell_widths, size)[ci].map(&:max)
      totwidth = colwidths.inject(&:+) + ((colwidths.length-1) * opts[:colsep].length)
      rcw = [rows_and_cols(list, size)[ri], colwidths] and break if totwidth <= opts[:displaywidth]
    end
    rcw
  end

  # TODO: find a better, more descriptive name for this function
  def rows_and_cols(list, ncols)
    # given list.size and ncols, calculate minimum number of rows needed. this is very cool.
    nrows = (list.size + ncols - 1) / ncols
    rows = (0...nrows).map {|r| list[r*ncols, ncols] }
    cols = rows[0].zip(*rows[1..-1]).map(&:compact)
    [rows, cols]
  end

  # Return the length of String +cell+. If Boolean +term_adjust+ is true, ignore terminal sequences in +cell+.
  def cell_size(cell, term_adjust)
    if term_adjust
      cell.gsub(/\e\[.*?m/, '')
    else
      cell
    end.size
  end
end
