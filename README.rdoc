= iCuke

iCuke allows you to test an iPhone application with cucumber. It provides a selection of step definitions similar to
those provided for testing web applications.

== Usage

Install the gem and load the iCuke step definitions in a cucumber support file:

require 'icuke/cucumber'

Write some scenarios like:

  Background:
    Given "iCuke" from "app/iCuke/iCuke.xcodeproj" is loaded in the simulator

  Scenario: User views the About screen
    When I tap "About"
    Then I should see "Author:"

== How it works

iCuke launches your application into the iPhone Simulator. A preload library is used to add a HTTP server into your
application.

The HTTP server allows us to see an XML version of the iPhone's screen, and to emulate taps/swipes etc.

iCuke should not require any code changes to your application to work, however, it relies on accessibility information
to function sensibly. If your accessibility information is not accurate, iCuke may not work as expected.

== Bugs

iCuke does not support testing applications on real devices, because I don't know of a way get a preload library to
load on the device.

iCuke does not support pinches yet. They'll be here soon!

iCuke compiles against the latest 3.1 and 4.0 SDKs it can find. Compiling against 3.2 is not currently supported as Apple have released two versions with different ABIs.

== Contributors

* Nigel Taylor
* Aslak Hellesøy
* Dominic Baggott
* Jeff Morgan
* Luke Redpath

== Thanks

Thanks go to the people who's work iCuke is based on:

* Matt Gallagher
* Ian Dees
* Felipe Barreto

== Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

== Copyright

Copyright (c) 2010 Unboxed Consulting. See LICENSE for details.
