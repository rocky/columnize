#!/usr/bin/env ruby
require 'test/unit'

# Test of Columnize module
class TestIssue3 < Test::Unit::TestCase
  @@TOP_SRC_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 
                            '..', 'lib')
  require File.join(@@TOP_SRC_DIR, 'columnize.rb')
  include Columnize
  # test columnize
  def test_long_column
    data = ["what's", "upppppppppppppppppp"]
    # Try at least one test where we give the module name explicitely.
    assert_equal("what's\nupppppppppppppppppp\n", 
                 Columnize::columnize(data, :arrange_vertical => false,
                                      :displaywidth => 7))
    assert_equal("what's\nupppppppppppppppppp\n", 
                 Columnize::columnize(data, :arrange_vertical => true,
                                      :displaywidth => 7))
    data = ["whaaaaaat's", "up"]
    assert_equal("whaaaaaat's\n         up\n",
                 Columnize::columnize(data, 
                                      :arrange_vertical => false,
                                      :ljust => false,
                                      :displaywidth => 7))
    assert_equal("whaaaaaat's\nup\n",
                 Columnize::columnize(data, 
                                      :arrange_vertical => false,
                                      :ljust => true,
                                      :displaywidth => 7))
    assert_equal("whaaaaaat's\nup\n",
                 Columnize::columnize(data, 
                                      :arrange_vertical => true,
                                      :ljust => true,
                                      :displaywidth => 7))
  end
end
