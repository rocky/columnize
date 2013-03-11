# Copyright (C) 2007-2011, 2013 Rocky Bernstein
# <rockyb@rubyforge.net>
#
# Part of Columnize to format in the horizontal direction
module Columnize
  module_function
  def columnize_horizontal(list, opts)
    nrows, ncols, colwidths = compute_rows_cols_and_width list, opts
    s = ''
    prefix = opts[:array_prefix].empty? ? opts[:lineprefix] : opts[:array_prefix]
    1.upto(nrows) do |row|
      page = (row-1)*ncols
      texts = list[page,ncols]
      0.upto(texts.size-1) do |col|
        unless ncols == 1 && opts[:ljust]
          if opts[:ljust]
            texts[col] = texts[col].ljust(colwidths[col]) if ncols != 1
          else
            texts[col] = texts[col].rjust(colwidths[col])
          end
        end
      end
      s += "%s%s%s" % [prefix, texts.join(opts[:colsep]), opts[:linesuffix]]
      prefix = opts[:lineprefix]
    end
    return s + opts[:array_suffix]
  end

  # compute the smallest number of rows and the max widths for each column
  def compute_rows_cols_and_width(list, opts)
    nrows = ncols = 0  # Make nrows, ncols have more global scope
    colwidths = []     # Same for colwidths
    # Assign to make enlarge scope of loop variables.
    totwidth = i = rounded_size = 0

    # Try every column count from size downwards.
    list.size.downto(1) do |_ncols|
      ncols = _ncols
      # Try every row count from 1 upwards
      min_rows = (list.size+ncols-1) / ncols
      min_rows.upto(list.size) do |_nrows|
        nrows = _nrows
        rounded_size = nrows * ncols
        colwidths = []
        totwidth = -opts[:colsep].length
        colwidth = row = 0
        0.upto(ncols-1) do |col|
          # get max column width for this column
          1.upto(nrows) do |_row|
            row = _row
            i = array_index(ncols, row, col)
            break if i >= list.size
            colwidth = [colwidth, cell_size(list[i], opts[:term_adjust])].max
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
    nrows = list.size if ncols == 1
    [nrows, ncols, colwidths]
  end

  def array_index(ncols, row, col)
    ncols*(row-1) + col
  end
end
