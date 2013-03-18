module Columnize
  computed_displaywidth = (ENV['COLUMNS'] || '80').to_i
  computed_displaywidth = 80 unless computed_displaywidth >= 10

  # When an option is not specified for the below keys, these are the defaults.
  DEFAULT_OPTS = {
    :arrange_array     => false,
    :arrange_vertical  => true,
    :array_prefix      => '',
    :array_suffix      => '',
    :colfmt            => nil,
    :colsep            => '  ',
    :displaywidth      => computed_displaywidth,
    :lineprefix        => '',
    :linesuffix        => "\n",
    :ljust             => :auto,
    :term_adjust       => false
  }

  # Add +columnize_opts+ instance variable to classes that mix in this module. The type should be a kind of hash as above.
  attr_accessor :columnize_opts

  # Adds class variable into any class mixes in this module.
  def self.included(base)
    base.class_variable_set :@@columnize_opts, DEFAULT_OPTS.dup if base.respond_to?(:class_variable_set)
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
    if 1 == args.size && args[0].kind_of?(Hash) # explicitly passed as a hash
      opts_from_hash args[0]
    elsif !args.empty? # passed as ugly positional parameters.
      opts_from_params args
    elsif defined?(@columnize_opts) # class has an option set as an instance variable.
      opts_from_hash @columnize_opts
    elsif defined?(@@columnize_opts) # class has an option set as a class variable.
      opts_from_hash @@columnize_opts.dup
    else  # When all else fails, just use the default options.
      opts_from_hash DEFAULT_OPTS.dup
    end
  end

  def opts_from_hash(hash)
    aa_opts = {:array_prefix => '[', :lineprefix => ' ', :linesuffix => ",\n", :array_suffix => "]\n", :colsep => ', ', :arrange_vertical => false}
    opts = DEFAULT_OPTS.merge(hash)
    opts.merge!(aa_opts) if opts[:arrange_array]
    opts
  end

  def opts_from_params(params)
    return DEFAULT_OPTS.dup if params.empty?
    DEFAULT_OPTS.merge Hash[params.zip([:displaywidth, :colsep, :arrange_vertical, :ljust, :lineprefix]).map(&:reverse)]
  end

  def working_displaywidth(displaywidth, lineprefix)
    if displaywidth - lineprefix.length < 4
      lineprefix.length + 4
    else
      displaywidth - lineprefix.length
    end
  end
end
