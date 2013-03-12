#!/usr/bin/env ruby
require 'test/unit'

# Test of Columnize#compute_rows_cols_and_width
class TestRowsAndCols < Test::Unit::TestCase
  # Ruby 1.8 form of require_relative
  TOP_SRC_DIR = File.join(File.expand_path(File.dirname(__FILE__)),
                            '..', 'lib')
  require File.join(TOP_SRC_DIR, 'columnize.rb')
  include Columnize

  OPTS = Columnize::DEFAULT_OPTS.merge(:arrange_vertical => false)

  def test_base
    assert_equal([1, 3, [8,8,8]], compute_rows_cols_and_width([1, 2, 3], OPTS))
    assert_equal([1, 3, [8,8,8]], compute_stuff([1, 2, 3], OPTS))
  end

  def test_colwidths
     data = ["one",      "two",         "three",
            "four",      "five",        "six",
            "seven",     "eight",       "nine",
            "ten",       "eleven",      "twelve",
            "thirteen",  "fourteen",    "fifteen",
            "sixteen",   "seventeen",   "eightteen",
            "nineteen",  "twenty",      "twentyone",
            "twentytwo", "twentythree", "twentyfour",
            "twentyfive","twentysix",   "twentyseven"]

    assert_equal([5, 6, [10, 9, 11, 9, 11, 10]], compute_rows_cols_and_width(data, OPTS))
    # assert_equal([5, 6, [10, 9, 11, 9, 11, 10]], compute_stuff(data, OPTS))
  end

  def test_horizontal_vs_vertical
    data = (0..54).map{|i| i.to_s}
    opts = OPTS.merge(:displaywidth => 39)
    assert_equal([6, 10, [2,2,2,2,2,2,2,2,2,2]], compute_rows_cols_and_width(data, opts))
    assert_equal([6, 10, [1,2,2,2,2,2,2,2,2,2]], compute_stuff(data, opts))

    # assert_equal(
    #         "0,  6, 12, 18, 24, 30, 36, 42, 48, 54\n" +
    #         "1,  7, 13, 19, 25, 31, 37, 43, 49\n" +
    #         "2,  8, 14, 20, 26, 32, 38, 44, 50\n" +
    #         "3,  9, 15, 21, 27, 33, 39, 45, 51\n" +
    #         "4, 10, 16, 22, 28, 34, 40, 46, 52\n" +
    #         "5, 11, 17, 23, 29, 35, 41, 47, 53\n",
    #         columnize(data, 39, ', ', true, false))

    # assert_equal(
    #         " 0,  1,  2,  3,  4,  5,  6,  7,  8,  9\n" +
    #         "10, 11, 12, 13, 14, 15, 16, 17, 18, 19\n" +
    #         "20, 21, 22, 23, 24, 25, 26, 27, 28, 29\n" +
    #         "30, 31, 32, 33, 34, 35, 36, 37, 38, 39\n" +
    #         "40, 41, 42, 43, 44, 45, 46, 47, 48, 49\n" +
    #         "50, 51, 52, 53, 54\n",
    #         columnize(data, 39, ', ', false, false))
  end

  def test_displaywidth_smaller_than_largest_atom
    data = ['a' * 100, 'b', 'c', 'd', 'e']
    assert_equal([5, 1, [100]], compute_rows_cols_and_width(data, OPTS))
    assert_equal([5, 1, [100]], compute_stuff(data, OPTS))
  end
end
