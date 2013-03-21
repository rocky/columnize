Columnize - Format an Array as a Column-aligned String
============================================================================

In showing a long lists, sometimes one would prefer to see the value
arranged aligned in columns. Some examples include listing methods of
an object, listing debugger commands, or showing a numeric array with data
aligned.

Setup
-----

    $ irb
    >> require 'columnize'
    => true

With numeric data
-----------------

    >> a = (1..10).to_a
    => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    >> a.columnize
    => "1  2  3  4  5  6  7  8  9  10\n"

    >> puts a.columnize :arrange_array => true, :displaywidth => 10
    [1, 2, 3,
     4, 5, 6,
     7, 8, 9,
     10,
    ]
    => nil

    >> puts a.columnize :arrange_array => true, :displaywidth => 20
    [1, 2, 3,  4, 5,  6,
     7, 8, 9, 10,
    ]
    => nil

With String data
----------------

    >> g = %w(bibrons golden madascar leopard mourning suras tokay)
    => ["bibrons", "golden", "madascar", "leopard", "mourning", "suras", "tokay"]

    >> puts g.columnize :displaywidth => 15
    bibrons   suras
    golden    tokay
    madascar
    leopard
    mourning
    => nil

    >> puts g.columnize :displaywidth => 19, :colsep => ' | '
    bibrons  | suras
    golden   | tokay
    madascar
    leopard
    mourning
    => nil

    >> puts g.columnize :displaywidth => 18, :colsep => ' | ', :ljust => false
    bibrons  | mourning
    golden   | suras
    madascar | tokay
    leopard
    => nil

Using Columnize.columnize
-------------------------

    >> Columnize.columnize(a)
    => "1  2  3  4  5  6  7  8  9  10\n"

    >> puts Columnize.columnize(a, :displaywidth => 10)
    1  5   9
    2  6  10
    3  7
    4  8
    => nil

    >> Columnize.columnize(g)
    => "bibrons  golden  madascar  leopard  mourning  suras  tokay\n"

    >> puts Columnize.columnize(g, :displaywidth => 19, :colsep => ' | ')
    bibrons  | mourning
    golden   | suras
    madascar | tokay
    leopard
    => nil


Credits
-------

This is adapted from a method of the same name from Python's cmd module.

Other stuff
-----------

Authors:   Rocky Bernstein <rockyb@rubyforge.org>
           [https://github.com/waslogic](Martin Davis)

License:   Copyright (c) 2011 Rocky Bernstein

Warranty
--------

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
