# Copyright (C) 2007-2011, 2013 Rocky Bernstein
# <rockyb@rubyforge.net>
#
# Part of Columnize to format in either direction
module Columnize
  class Columnizer
    ARRANGE_ARRAY_OPTS = {:array_prefix => '[', :line_prefix => ' ', :line_suffix => ",\n", :array_suffix => "]\n", :colsep => ', ', :arrange_vertical => false}
    OLD_AND_NEW_KEYS = {:lineprefix => :line_prefix, :linesuffix => :line_suffix}

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

    def opts=(opts)
      @opts = opts
      OLD_AND_NEW_KEYS.each {|old, new| @opts[new] = @opts.delete(old) if @opts.keys.include?(old) and !@opts.keys.include?(new) }
      @opts.merge!(ARRANGE_ARRAY_OPTS) if @opts[:arrange_array]
      @opts[:ljust] = !@list.all? {|datum| datum.kind_of?(Numeric)} if @opts[:ljust] == :auto
      adjust_displaywidth
      @stringify = @opts[:colfmt] ? lambda {|li| @opts[:colfmt] % li } : lambda {|li| li.to_s }
    end

    def update_opts(opts)
      self.opts = @opts.merge(opts)
    end

    def columnize
      return @short_circuit if @short_circuit

      rows, colwidths = compute_rows_and_colwidths
      ncols = colwidths.length
      justify = lambda {|t, c| @opts[:ljust] ? t.ljust(colwidths[c]) : t.rjust(colwidths[c]) }
      textify = lambda do |s, row|
        row.map!.with_index(&justify) unless ncols == 1 && @opts[:ljust]
        s + "#{@opts[:line_prefix]}#{row.join(@opts[:colsep])}#{@opts[:line_suffix]}"
      end

      text = rows.inject('', &textify)
      text = text.sub(@opts[:line_prefix], @opts[:array_prefix]) + @opts[:array_suffix] unless @opts[:array_prefix].empty?
      text
    end

    # TODO: make this a method, rather than a function (?)
    # compute the smallest number of rows and the max widths for each column
    def compute_rows_and_colwidths
      list = @list.map &@stringify
      cell_widths = list.map {|x| cell_size x }
      # default is 1 atom per row (just in case any atom > @opts[:displaywidth])
      rcw = [rows_and_cols(list, 1)[0], [cell_widths.max]]
      return rcw if rcw[1][0] > @opts[:displaywidth]

      # TODO: explain why
      sizes, ri, ci = (1..list.length).to_a, 1, 0
      sizes, ri, ci = sizes.reverse, 0, 1 unless @opts[:arrange_vertical]

      sizes.each do |size|
        colwidths = rows_and_cols(cell_widths, size)[ci].map(&:max)
        totwidth = colwidths.inject(&:+) + ((colwidths.length-1) * @opts[:colsep].length)
        rcw = [rows_and_cols(list, size)[ri], colwidths] and break if totwidth <= @opts[:displaywidth]
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
    def cell_size(cell)
      if @opts[:term_adjust]
        cell.gsub(/\e\[.*?m/, '')
      else
        cell
      end.size
    end

    def adjust_displaywidth
      if @opts[:displaywidth] - @opts[:line_prefix].length < 4
        @opts[:displaywidth] = @opts[:line_prefix].length + 4
      else
        @opts[:displaywidth] -= @opts[:line_prefix].length
      end
    end

    def set_attrs_from_opts
      # TODO: START HERE: make everything that can be an attr, be an attr
    end
  end
end
