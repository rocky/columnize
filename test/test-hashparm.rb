#!/usr/bin/env ruby
require 'test/unit'

# Test of Columnize module
class TestHashFormat < Test::Unit::TestCase
  TOP_SRC_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 
                          '..', 'lib')
  require File.join(TOP_SRC_DIR, 'columnize.rb')
  include Columnize
  def test_parse_columnize_options
    list, default_opts = parse_columnize_options([[], {}])
    assert list.kind_of?(Array)
    assert default_opts.kind_of?(Hash)
    list, opts = parse_columnize_options([[], 90])
    assert_equal 90, opts[:displaywidth]
    list, opts = parse_columnize_options([[], 70, '|'])
    assert_equal 70, opts[:displaywidth]
    assert_equal '|', opts[:colsep]
  end

  def test_new_hash
    list, opts = parse_columnize_options([[], {:displaywidth => 40,
                                          :colsep => ', ',
                                          :term_adjust => true,
                                          }])
    [[:displaywidth, 40], [:colsep, ', '], [:term_adjust, true]].each do 
       |field, value|
       assert_equal(value , opts[field])
     end
    list, opts = parse_columnize_options([[], {:displaywidth => 40,
                                          :colsep => ', ',
                                          }])
    assert_equal(false , opts[:term_adjust])
  end
  
  def basic
    opts = {:xxx => 10, :yyy => ', '}
    assert_equal("1, 2, 3\n", 
                 Columnize::columnize([1, 2, 3], opts))
  end
end
