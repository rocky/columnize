#!/usr/bin/env ruby
require 'test/unit'

# Test of Columnize#compute_rows_and_colwidths
class TestComputeRowsAndColwidths < Test::Unit::TestCase
  # Ruby 1.8 form of require_relative
  TOP_SRC_DIR = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib')
  require File.join(TOP_SRC_DIR, 'columnize.rb')

  VOPTS = Columnize::DEFAULT_OPTS
  HOPTS = VOPTS.merge(:arrange_vertical => false)

  def compute_rows_and_colwidths(list, opts)
    Columnize::Columnizer.new(list, opts).compute_rows_and_colwidths
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

    # horizontal
    rows, colwidths = compute_rows_and_colwidths(data, HOPTS)
    assert_equal([10, 9, 11, 9, 11, 10], colwidths, "colwidths")
    assert_equal(5, rows.length, "number of rows")
    assert_equal(6, rows.first.length, "number of cols")
    # vertical
    rows, colwidths = compute_rows_and_colwidths(data, VOPTS)
    assert_equal([5, 5, 6, 8, 9, 11, 11], colwidths, "colwidths")
    assert_equal(4, rows.length, "number of rows")
    assert_equal(7, rows.first.length, "number of cols")
  end

  def test_horizontal_vs_vertical
    data = (0..54).map{|i| i.to_s}
    # horizontal
    rows, colwidths = compute_rows_and_colwidths(data, HOPTS.merge(:displaywidth => 39))
    assert_equal([2,2,2,2,2,2,2,2,2,2], colwidths, "colwidths")
    assert_equal(6, rows.length, "number of rows")
    assert_equal(10, rows.first.length, "number of cols")
    # vertical
    rows, colwidths = compute_rows_and_colwidths(data, VOPTS.merge(:displaywidth => 39))
    assert_equal([1,2,2,2,2,2,2,2,2,2], colwidths, "colwidths")
    assert_equal(6, rows.length, "number of rows")
    assert_equal(10, rows.first.length, "number of cols")
  end

  def test_displaywidth_smaller_than_largest_atom
    data = ['a' * 100, 'b', 'c', 'd', 'e']
    # horizontal
    rows, colwidths = compute_rows_and_colwidths(data, HOPTS)
    assert_equal([100], colwidths, "colwidths")
    assert_equal(5, rows.length, "number of rows")
    assert_equal(1, rows.first.length, "number of cols")
    # vertical
    rows, colwidths = compute_rows_and_colwidths(data, VOPTS)
    assert_equal([100], colwidths, "colwidths")
    assert_equal(5, rows.length, "number of rows")
    assert_equal(1, rows.first.length, "number of cols")
  end
end
