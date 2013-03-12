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

    nrows = ncols = 0  # Make nrows, ncols have more global scope
    colwidths = []     # Same for colwidths
    # Assign to make enlarge scope of loop variables.
    totwidth = i = rounded_size = 0

    # Try every column count from size downwards.
    list.size.downto(1) do |_ncols|
      ncols = _ncols
      # Try every row count from 1 upwards
      min_rows = (list.size+ncols-1) / ncols # this is very cool
      min_rows.upto(list.size) do |_nrows|
        nrows = _nrows
        rounded_size = nrows * ncols
        colwidths = []
        totwidth = -opts[:colsep].length
        colwidth = row = 0

        # _, col_widths = rows_and_cols(cell_widths, nrows, ncols)
        # colwidths = col_widths.map(&:max)
        # totwidth = colwidths.inject(&:+) + ((ncols-1) * opts[:colsep].length)

        (0...ncols).each do |col|
          # get max column width for this column
          1.upto(nrows) do |_row|
            row = _row
            i = ncols*(row-1) + col
            break if i >= list.size
            colwidth = [colwidth, cell_size(list[i], opts[:term_adjust])].max
          end
          colwidths.push(colwidth)
          totwidth += colwidth + opts[:colsep].length
        end
        nrows = row if totwidth <= opts[:displaywidth]
        break
      end
      break if totwidth <= opts[:displaywidth] and i >= rounded_size-1 # START HERE: figure out why i needs to be bigger
    end
    ncols = 1 if ncols < 1
    nrows = list.size if ncols == 1
    [nrows, ncols, colwidths]
  end

  def rows_and_cols(list, nrows, ncols)
    rows = (0...nrows).map {|r| list[r*ncols, ncols] }
    cols = rows[0].zip(*rows[1..-1]).map(&:compact)
    return rows, cols
  end
end
