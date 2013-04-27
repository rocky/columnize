# Copyright (C) 2007-2011, 2013 Rocky Bernstein
# <rockyb@rubyforge.net>
#
# Part of Columnize to format in either direction
module Columnize
  class Columnizer
    ARRANGE_ARRAY_OPTS = {:array_prefix => '[', :line_prefix => ' ', :line_suffix => ',', :array_suffix => ']', :colsep => ', ', :arrange_vertical => false}
    OLD_AND_NEW_KEYS = {:lineprefix => :line_prefix, :linesuffix => :line_suffix}
    # TODO: change colfmt to cell_format; change colsep to something else
    ATTRS = [:arrange_vertical, :array_prefix, :array_suffix, :line_prefix, :line_suffix, :colfmt, :colsep, :displaywidth, :ljust]

    attr_reader :list, :opts

    def initialize(list=[], opts={})
      self.list = list
      self.opts = DEFAULT_OPTS.merge(opts)
    end

    def list=(list)
      @list = list
      if @list.is_a? Array
        @short_circuit = @list.empty? ? "<empty>\n" : nil
      else
        @short_circuit = ''
        @list = []
      end
    end

    # TODO: freeze @opts
    def opts=(opts)
      @opts = opts
      OLD_AND_NEW_KEYS.each {|old, new| @opts[new] = @opts.delete(old) if @opts.keys.include?(old) and !@opts.keys.include?(new) }
      @opts.merge!(ARRANGE_ARRAY_OPTS) if @opts[:arrange_array]
      set_attrs_from_opts
    end

    def update_opts(opts)
      self.opts = @opts.merge(opts)
    end

    def columnize
      return @short_circuit if @short_circuit

      rows, colwidths = compute_rows_and_colwidths
      ncols = colwidths.length
      justify = lambda {|t, c| @ljust ? t.ljust(colwidths[c]) : t.rjust(colwidths[c]) }
      textify = lambda do |row|
        row.map!.with_index(&justify) unless ncols == 1 && @ljust
        "#{@line_prefix}#{row.join(@colsep)}#{@line_suffix}"
      end

      text = rows.map(&textify)
      text.first.sub!(/^#{@line_prefix}/, @array_prefix) unless @array_prefix.empty?
      text.last.sub!(/#{@line_suffix}$/, @array_suffix) unless @array_suffix.empty?
      text.join("\n") # + "\n" # if we want extra separation
    end

    # TODO: make this a method, rather than a function (?)
    # compute the smallest number of rows and the max widths for each column
    def compute_rows_and_colwidths
      list = @list.map &@stringify
      cell_widths = list.map(&@term_adjuster).map(&:size)

      # Set default rcw: one atom per row
      cell_width_max = cell_widths.max
      result = [arrange_rows_and_cols(list, 1)[0], [cell_width_max]]

      # If any atom > @displaywidth, stop and use one atom per row.
      return result if cell_width_max > @displaywidth

      # For horizontal arrangement, we want to *maximize* the number
      # of columns. Thus the candidate number of rows (+sizes+) starts
      # at the minumum number of rows, 1, and increases.

      # For vertical arrangement, we want to *minimize* the number of
      # rows. So here the candidate number of columns (+sizes+) starts
      # at the maximum number of columns, list.length, and
      # decreases. Also the roles of columns and rows are reversed
      # from horizontal arrangement.

      # The below sets up the order of the lengths to try, +sizes+. It
      # also sets up the row and column permutation to use, [0,1] or
      # [1,0], which are stored in +ri+, +ci+ in accessing the tuple
      # values passed back by arrange_rows_and_cols().
      sizes, ri, ci =
        if @arrange_vertical
          [(1..list.length).to_a, 1, 0]
        else
          [(1..list.length).to_a.reverse, 0, 1]
        end

      # Loop from most compact arrangement to least compact, stopping
      # at the first successful packing.  The below code is tricky,
      # but very cool.
      sizes.each do |size|
        colwidths = arrange_rows_and_cols(cell_widths, size)[ci].map(&:max)
        totwidth = colwidths.inject(&:+) + ((colwidths.length-1) * @colsep.length)
        result = [arrange_rows_and_cols(list, size)[ri], colwidths]
        break if totwidth <= @displaywidth
      end
      result
    end

    # Given +list+ and +ncols+, arrange the one-dimensional array into two
    # 2-dimensional lists of lists. One list is organized by rows and
    # the other list organized by columns.
    #
    # In either horizontal or vertical arrangement, we will need to
    # make use of in both lists.
    #
    # Here is an example:
    # arrange_row_and_cols((1..5).to_a, 2) =>
    #   [
    #    [[1,2], [3,4], [5]],
    #    [[1,3,5], [2,4]]
    #   ]
    def arrange_rows_and_cols(list, ncols)
      nrows = (list.size + ncols - 1) / ncols
      rows = (0...nrows).map {|r| list[r*ncols, ncols] }
      cols = rows[0].zip(*rows[1..-1]).map(&:compact)
      [rows, cols]
    end

    def set_attrs_from_opts
      ATTRS.each {|attr| self.instance_variable_set "@#{attr}", @opts[attr] }

      @ljust = !@list.all? {|datum| datum.kind_of?(Numeric)} if @ljust == :auto
      @displaywidth -= @line_prefix.length
      @displaywidth = @line_prefix.length + 4 if @displaywidth < 4
      @stringify = @colfmt ? lambda {|li| @colfmt % li } : lambda {|li| li.to_s }
      @term_adjuster = @opts[:term_adjust] ? lambda {|c| c.gsub(/\e\[.*?m/, '') } : lambda {|c| c }
    end
  end
end
