Fallow
======

A blogging engine, characterized by inactivity.

I'm more or less teaching myself Ruby as I go, so look at this as nothing more than a learning-by-doing experiment.  Therefore, fallow will likely never function properly for anyone other than me, and that's ok.  Fallow has low aspirations.

TODO
----

*   Learn how unit testing works in Ruby and Rack (Ryan Tomayko's [Wink][]
    looks like a good place to sift around for testing strategies)
    
*   Come up with a solid templating system.  ERB is kinda crap.  Maybe just
    write something simple that implements something vaguely similar to flat
    PHP `include` and `strtr`?

*   Bash things together until a more reasonable architecture falls out. 
    Passing around a `Rack::Request` seems like a bad idea.

    *   Buy a whiteboard.  I can't architect on paper.  :(
    
[wink]: http://github.com/rtomayko/wink/tree/master/test "wink's test suite"