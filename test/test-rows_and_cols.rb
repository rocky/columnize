#!/usr/bin/env ruby
require 'test/unit'

# Test of Columnize#compute_rows_cols_and_width
class TestRowsAndCols < Test::Unit::TestCase
  # Ruby 1.8 form of require_relative
  TOP_SRC_DIR = File.join(File.expand_path(File.dirname(__FILE__)),
                            '..', 'lib')
  require File.join(TOP_SRC_DIR, 'columnize.rb')
  include Columnize

  OPTS = Columnize::DEFAULT_OPTS.dup

  def test_base
    assert_equal([1, 3, [8,8,8]], compute_rows_cols_and_width([1, 2, 3], OPTS))
  end

  def test_colwidths
     data = ["one",       "two",         "three",
            "for",       "five",        "six",
            "seven",     "eight",       "nine",
            "ten",       "eleven",      "twelve",
            "thirteen",  "fourteen",    "fifteen",
            "sixteen",   "seventeen",   "eightteen",
            "nineteen",  "twenty",      "twentyone",
            "twentytwo", "twentythree", "twentyfour",
            "twentyfive","twentysix",   "twentyseven"]

    assert_equal([5, 6, [10, 9, 11, 9, 11, 10]], compute_rows_cols_and_width(data, OPTS))
  end

  def test_displaywidth_smaller_than_largest_atom
    data = ['a' * 100, 'b', 'c', 'd', 'e']
    assert_equal([5, 1, [100]], compute_rows_cols_and_width(data, OPTS))
  end
end
