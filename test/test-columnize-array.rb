#!/usr/bin/env ruby
require 'test/unit'

# Test of Columnize module
class TestColumnizeArray < Test::Unit::TestCase

  # Ruby 1.8 form of require_relative
  TOP_SRC_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 
                            '..', 'lib')
  require File.join(TOP_SRC_DIR, 'columnize.rb')

  # test columnize
  def test_basic

    a = (1..80).to_a
    a.columnize_opts = {:arrange_array => true}
    expect = <<EOF
[ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60,
 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
]
EOF
    self.assert_equal(expect, a.columnize, "arrange_arrary => true (1..80)")

    expect = <<EOF
1  5   9
2  6  10
3  7
4  8
EOF
    test_str = "(1..10).to_a.columnize(:displaywidth=>10)"
    self.assert_equal(expect, eval(test_str), test_str)

    expect = <<EOF
[01, 02,
 03, 04,
 05, 06,
 07, 08,
 09, 10,
]
EOF
    test_str = "(1..10).to_a.columnize(:arrange_array=>true,:colfmt=>'%02d',:displaywidth=>10)"
    self.assert_equal(expect, eval(test_str), test_str)

  end
end
