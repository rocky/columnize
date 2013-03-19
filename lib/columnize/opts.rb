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
    :line_prefix        => '',
    :line_suffix        => "\n",
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
  # +ljust+, and +line_prefix+.
  #
  # Thanks to ideas from Martin Davis, failing any explicit setting on
  # the columnize method call, we also now allow options to be picked
  # up from a columnize_opts instance variable or columnize_opts class
  # variable.
  def parse_columnize_options(args)
    if 1 == args.size && args[0].kind_of?(Hash) # explicitly passed as a hash
      args[0]
    elsif !args.empty? # passed as ugly positional parameters.
      Hash[args.zip([:displaywidth, :colsep, :arrange_vertical, :ljust, :line_prefix]).map(&:reverse)]
    elsif defined?(@columnize_opts) # class has an option set as an instance variable.
      @columnize_opts
    elsif defined?(@@columnize_opts) # class has an option set as a class variable.
      @@columnize_opts
    else  # When all else fails, just use the default options.
      {}
    end
  end
end
