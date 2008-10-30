Fallow
======

A blogging engine, characterized by inactivity.

I'm more or less teaching myself Ruby as I go, so look at this as nothing more than a learning-by-doing experiment.  Therefore, fallow will likely never function properly for anyone other than me, and that's ok.  Fallow has low aspirations.


Blockers
--------
*   Design adhoc pages
*   Populate adhoc pages for '/is/' and '/resume/'.  The latter might just be a redirect to a pdf on 'static.*' for the moment.
*   Solid nginx configuration
*   Solid thin configuration
*   Cronjobs for del.icio.us aggregation

TODO Eventually
---------------

*   Tags on archive page (will require some template rework: requires `include_multiple` inside an `include_multiple`'d template)
*   Links to del.icio.us URL info page (ditto: needs some form of `if`)
*   Flickr aggregation
*   Twitter aggregation
*   RSS feeds for tag clouds
*   Tag cloud for `/tags/` (Right now it's a 404)
*   Archive landing page for `/archive/` (Right now it's a 302 to the current year)
*   Pagination and navigation for tags, archive, etc.