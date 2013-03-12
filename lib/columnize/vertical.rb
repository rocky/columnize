# Copyright (C) 2007-2011, 2013 Rocky Bernstein
# <rockyb@rubyforge.net>
#
# Part of Columnize to format in the vertical direction
module Columnize
  module_function
  def columnize_vertical(list, opts)
    nrows, ncols, colwidths = compute_stuff(list, opts)
    # nrows, ncols, colwidths = compute_rows_cols_and_width(list, opts)
    array_index = lambda {|num_rows, row, col| num_rows*col + row }
    # The smallest number of rows computed and the max widths for each column has been obtained.
    # Now we just have to format each of the rows.
    (0...nrows).inject('') do |s, _row|
      row = _row
      texts = []
      0.upto(ncols-1) do |col|
        i = array_index.call(nrows, row, col)
        if i >= list.size
          x = ''
        else
          x = list[i]
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
        s += "%s%s%s" % [opts[:lineprefix], texts.join(opts[:colsep]), opts[:linesuffix]]
      end
      s
    end
  end

  # vertical rows and columns differ from horizontal rows and columns!
  def compute_stuff(list, opts)
    nrows = ncols = 0  # Make nrows, ncols have more global scope
    colwidths = []     # Same for colwidths
    array_index = lambda {|num_rows, row, col| num_rows*col + row }
    # Try every row count from 1 upwards
    1.upto(list.size-1) do |_nrows|
      nrows = _nrows
      ncols = (list.size + nrows-1) / nrows
      colwidths = []
      totwidth = -opts[:colsep].length

      0.upto(ncols-1) do |col|
        # get max column width for this column
        colwidth = 0
        0.upto(nrows-1) do |_row|
          row = _row
          i = array_index.call(nrows, row, col)
          break if i >= list.size
          colwidth = [colwidth, cell_size(list[i], opts[:term_adjust])].max
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
    nrows = list.size if ncols == 1
    [nrows, ncols, colwidths]
  end

  def v_rows_and_cols(list, nrows, ncols)
    puts [list, nrows, ncols].inspect
    cols = (0...ncols).map {|c| list[c*nrows, nrows] }.compact
    puts "cols: #{cols.inspect}"
    rows = cols[0].zip(*cols[1..-1]).map(&:compact)
    [rows, cols]
  end
end
