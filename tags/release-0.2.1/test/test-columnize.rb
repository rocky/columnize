#!/usr/bin/env ruby
require "test/unit"

# Test of Columnize module
class TestColumnize < Test::Unit::TestCase
  @@TOP_SRC_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 
                            '..', 'lib')
  require File.join(@@TOP_SRC_DIR, 'columnize.rb')
  include Columnize
  
  # test columnize
  def test_basic
    # Try at least one test where we give the module name explicitely.
    assert_equal("1, 2, 3\n", 
                 Columnize::columnize([1, 2, 3], 10, ', '))
    assert_equal("", columnize(5))
    assert_equal("1  3\n2  4\n", 
                 columnize(['1', '2', '3', '4'], 4))
    assert_equal("1  2\n3  4\n", 
                 columnize(['1', '2', '3', '4'], 4, '  ', false))
    assert_equal("<empty>\n", columnize([]))
    assert_equal("oneitem\n", columnize(["oneitem"]))
    data = ["one",       "two",         "three",
            "for",       "five",        "six",
            "seven",     "eight",       "nine",
            "ten",       "eleven",      "twelve",
            "thirteen",  "fourteen",    "fifteen",
            "sixteen",   "seventeen",   "eightteen",
            "nineteen",  "twenty",      "twentyone",
            "twentytwo", "twentythree", "twentyfour",
            "twentyfive","twentysix",   "twentyseven"]

     assert_equal(
 "one         two        three        for        five         six       \n" +
 "seven       eight      nine         ten        eleven       twelve    \n" +
 "thirteen    fourteen   fifteen      sixteen    seventeen    eightteen \n" +
 "nineteen    twenty     twentyone    twentytwo  twentythree  twentyfour\n" +
 "twentyfive  twentysix  twentyseven\n", columnize(data, 80, '  ', false))

    assert_equal(
"one    five   nine    thirteen  seventeen  twentyone    twentyfive \n" +
"two    six    ten     fourteen  eightteen  twentytwo    twentysix  \n" +
"three  seven  eleven  fifteen   nineteen   twentythree  twentyseven\n" +
"for    eight  twelve  sixteen   twenty     twentyfour \n", columnize(data))

  end
end
