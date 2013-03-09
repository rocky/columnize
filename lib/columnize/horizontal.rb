# Copyright (C) 2007-2011, 2013 Rocky Bernstein
# <rockyb@rubyforge.net>
#
# Part of Columnize to format in the horizontal direction
module Columnize
  module_function
  def columnize_horizontal(l, opts)
    nrows = ncols = 0  # Make nrows, ncols have more global scope
    colwidths = []     # Same for colwidths
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
