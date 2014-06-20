Ingress Screnshot
=================

To get started, clone this repository with

    git clone https://github.com/rperce/ingress-screenshot.git

and then `cd` into the new `ingress-screenshot` directory.

Run the following to get set up:

    chmod +x run.rb
    ./run.rb -g

You'll need a firefox profile called something unique; run `firefox -P` to set that up if you haven't already. Log in to ingress.com/intel.  You'll have to re-login every few weeks.

You'll also need to know the url of the view you wish to screenshot.

With the above in hand, edit the newly created `default.cfg` to your liking and name it something unique.
The configuration options are detailed below.

Finally, run the software with 
    ./run.rb -c <config>

Configuration
-------------

- `interval`: keys in this mapping are times at which the delay between screenshots changes.  No screenshots will be taken until the first listed time; the program will exit after the time for which the delay is `end`.
- `folder`: folder in which images will be stored.   Useful for running multiple instances at the same time to prevent conflict.
- `ff_profile`: unique profile name you set up earlier
- `ff_profile_dir`: directory of the above profile
- `ff_wait`: number of seconds to wait for firefox to load before taking a screenshot
- `ff_url`: url to take a screenshot of
- `xvfb_res_width`: width of the virtual X11 server
- `xvfb_res_height`: height of the virtual X11 server
- `xvfb_display`: virtual display on which to run
- `ss_width`: final width of the screenshot
- `ss_height`: final height of the screenshot
- `ss_offset_left`: left-side offset of screenshot area
- `ss_offset_top`: top-side offset of screenshot area
- `timestamp`: if false, do not overlay timestamp on the images; if true do so.
