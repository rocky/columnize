#!/usr/bin/env ruby
require 'test/unit'

# Test of Columnizer class
class TestColumnizer < Test::Unit::TestCase
  TOP_SRC_DIR = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib')
  require File.join(TOP_SRC_DIR, 'columnize.rb')

  # SETTING OPTS IN INITIALIZE
  def test_passed_in_opts
    # passed in opts should be merged with DEFAULT_OPTS
    c = Columnize::Columnizer.new([], :displaywidth => 15)
    assert_equal false, c.opts[:term_adjust], 'term_adjust comes from DEFAULT_OPTS'
    assert_equal 15, c.opts[:displaywidth], 'displaywidth should override DEFAULT_OPTS'
  end

  def test_ljust_opt
    c = Columnize::Columnizer.new([1,2,3], {:ljust => :auto})
    assert_equal false, c.opts[:ljust], 'ljust: :auto should transform to false when all values are numeric'
    c = Columnize::Columnizer.new(['1', 2, 3], {:ljust => :auto})
    assert_equal true, c.opts[:ljust], 'ljust: :auto should transform to true when not all values are numeric'
    c = Columnize::Columnizer.new([], {:ljust => false})
    assert_equal false, c.opts[:ljust], 'ljust: false should stay false'
    c = Columnize::Columnizer.new([], {:ljust => true})
    assert_equal true, c.opts[:ljust], 'ljust: true should stay true'
  end

  def test_stringify_attr
    stringify = Columnize::Columnizer.new.instance_variable_get(:@stringify)
    assert_equal '1', stringify[1], 'without colfmt, should be to_s'
    stringify = Columnize::Columnizer.new([], :colfmt => '%02d').instance_variable_get(:@stringify)
    assert_equal '01', stringify[1], 'without colfmt, should be to_s'
  end

  def test_short_circuit_attr
    c = Columnize::Columnizer.new
    assert_equal "<empty>\n", c.instance_variable_get(:@short_circuit), 'should explicitly state when empty'
    c.list = 1
    assert_equal '', c.instance_variable_get(:@short_circuit), 'should be an empty string when not an array'
    c.list = [1]
    assert_equal nil, c.instance_variable_get(:@short_circuit), 'should be nil when list is good'
  end

  # TODO: test list= and opts=

  # COLUMNIZE
  def test_columnize_with_short_circuit
    msg = 'Johnny 5 is alive!'
    c = Columnize::Columnizer.new
    c.instance_variable_set(:@short_circuit, msg)
    assert_equal msg, c.columnize, 'columnize should return short_circuit message if set'
  end

  def test_columnize_applies_ljust
    c = Columnize::Columnizer.new [1,2,3,10,20,30], :displaywidth => 10, :ljust => false, :arrange_vertical => false
    assert_equal " 1   2   3\n10  20  30\n", c.columnize, "ljust: #{c.opts[:ljust]}"
    c.opts[:ljust] = true
    assert_equal "1   2   3 \n10  20  30\n", c.columnize, "ljust: #{c.opts[:ljust]}"
  end

  def test_columnize_applies_colsep_and_prefix_and_suffix
    c = Columnize::Columnizer.new [1,2,3]
    assert_equal "1  2  3\n", c.columnize
    c.opts[:line_prefix], c.opts[:colsep], c.opts[:line_suffix] = ['>', '-', '<']
    assert_equal ">1-2-3<", c.columnize
  end

  def test_columnize_applies_array_prefix_and_suffix
    c = Columnize::Columnizer.new [1,2,3]
    assert_equal "1  2  3\n", c.columnize
    c.opts[:array_prefix], c.opts[:array_suffix] = ['>', '<']
    assert_equal ">1  2  3\n<", c.columnize
  end

  # NOTE: compute_rows_and_colwidths tested in test-compute_rows_and_colwidths.rb

  # ROWS_AND_COLS
  def test_rows_and_cols
    rows,cols = Columnize::Columnizer.new.rows_and_cols((1..9).to_a, 3)
    assert_equal [[1,2,3],[4,5,6],[7,8,9]], rows, 'rows'
    assert_equal [[1,4,7],[2,5,8],[3,6,9]], cols, 'cols'
  end

  def test_cell_size
    c = Columnize::Columnizer.new
    assert_equal(3, c.cell_size('abc'))
    assert_equal(19, c.cell_size("\e[0;31mObject\e[0;4m"))
    c.opts[:term_adjust] = true
    assert_equal(3, c.cell_size('abc'))
    assert_equal(6, c.cell_size("\e[0;31mObject\e[0;4m"))
  end

  def test_adjust_display_width
    c = Columnize::Columnizer.new [], :displaywidth => 10, :line_prefix => '        '
    assert_equal 12, c.opts[:displaywidth], 'displaywidth within 4 of line_prefix.length'
    c.opts[:displaywidth] = 10
    c.opts[:line_prefix] = '  '
    c.adjust_displaywidth
    assert_equal 8, c.opts[:displaywidth], 'displaywidth not within 4 of line_prefix.length'
  end

  def test_set_attrs_from_opts
    assert(true, 'test set_attrs_from_opts')
  end
end
