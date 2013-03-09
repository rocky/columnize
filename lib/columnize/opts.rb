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
  module_function
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

end
