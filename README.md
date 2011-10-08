Columnize - Format an Array as a Column-aligned String
============================================================================

In showing a long lists, sometimes one would prefer to see the value
arranged aligned in columns. Some examples include listing methods of
an object, listing debugger commands, or showing a numeric array with data
aligned.

Setup
-----

    $ irb
    >> a = (1..10).to_a
    => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    >> require 'columnize'
    => true
    >> include Columnize
    => Object
    >> g = %w(bibrons golden madascar leopard mourning suras tokay)
    => ["bibrons", "golden", "madascar", "leopard", "mourning", "suras", "tokay"]

With numeric data
-----------------

    columnize(a) 
    => "1  2  3  4  5  6  7  8  9  10\n"
    >> puts Columnize::columnize(a, :arrange_array => true, :displaywidth => 10)
    [1,  2
     3,  4
     5,  6
     7,  8
     9, 10
    ]
    => nil
    >> puts Columnize::columnize(a, :arrange_array => true, :displaywidth => 20)
    [1, 2, 3,  4,  5,  6
     7, 8, 9, 10
    ]

With String data
----------------

    >> puts columnize g, :displaywidth => 15
    bibrons   suras
    golden    tokay
    madascar
    leopard 
    mourning
    => nil

    >> puts columnize g, {:displaywidth => 19, :colsep => ' | '}
    bibrons  | suras
    golden   | tokay
    madascar
    leopard 
    mourning
    => nil

    >> puts columnize g, {:displaywidth => 18, :colsep => ' | ', :ljust=>false}

    bibrons  | mourning
    golden   | suras   
    madascar | tokay   
    leopard 

Credits
-------

This is adapted from a method of the same name from Python's cmd module.

Other stuff
-----------

Author:   Rocky Bernstein <rockyb@rubyforge.org>

License:  Copyright (c) 2011 Rocky Bernstein

Warranty
--------

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
