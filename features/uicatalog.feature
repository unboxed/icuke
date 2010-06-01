Feature: iPhone integration tests
  In order to test my iphone application
  As a tester
  I want cucumber to be able to drive the simulator

  Background:
    Given "app/UICatalog.xcodeproj" is loaded in the simulator

  Scenario: Navigating through the application
    When I tap "Buttons"
    And I tap "Back"
    And I tap "Controls"
    And I tap "Back"
    And I tap "TextFields"
    And I tap "Back"
    And I tap "SearchBar"
    And I tap "Back"
    And I tap "TextView"
    And I tap "Back"
    And I tap "Images"
    And I tap "Back"
    And I tap "Web"
    And I tap "Back"
    And I tap "Segment"
    And I tap "Back"
    And I scroll down
    And I tap "Toolbar"
    And I tap "Back"
    And I tap "Alerts"
    And I tap "Back"
    And I tap "Transitions"
    And I tap "Back"
    
  Scenario: Scrolling up and down
    When I tap "Buttons"
    And I scroll down
    And I scroll up
    And I tap "Back"
    And I scroll down
    And I tap "Transitions"

  Scenario: Pressing buttons
    When I tap "Buttons"
    And I tap "Gray"
    And I tap "Right pointing arrow"
    And I tap "Rounded"
    And I scroll down
    And I tap "More info"
    And I tap "Add contact"

  Scenario: Switches and sliders
    When I tap "Controls"
    And I tap "Standard switch"
    Then show me the screen
    
  Scenario: Finding text
    When I tap "TextView"
    Then I should see "Now is the time for all good developers to come to serve their country."

  Scenario: Entering text
    When I tap "TextFields"
    And I type "A string with symb0ls $!@ and spaces in it" in "Normal"
    And I type "cucumber for iphone" in "Rounded"
    And I type "secret" in "Secure"
    Then I should see "A string with symb0ls $!@ and spaces in it"
    And I should see "cucumber for iphone"

  Scenario: Segment
    When I tap "Segment"
    And I tap "Check"
    And I tap "Search"
    And I tap "Tools"

  Scenario: Web
    When I tap "Web"
    And I tap "Clear text"
    And I type "http://www.leandog.com" in "URL entry"

  Scenario: Toolbar
    When I scroll down
    And I tap "Toolbar"
    And I tap "Black"
    And I tap "Translucent"
    And I tap "Default"
    And I tap "Tinted"
    And I tap "Bordered"
    And I tap "Plain"
    And I tap "Item"
    And I tap "Done"

  Scenario: Transitions
    When I scroll down
    And I tap "Transitions"
    And I tap "Flip Image"
    And I tap "Flip Image"
    And I tap "Curl Image"
    And I tap "Curl Image"

  Scenario: Draging
    And I tap "Controls"
    When I drag from 258,285 to 319,285
    And I drag from 244,439 to 319,439
    And I tap "Back"
    And I scroll down
    And I tap "Toolbar"
    And I drag from 97,400 to 97,233
    And I tap "Back"

  Scenario: Alerts
    When I scroll down
    And I tap "Alerts"
    Then show me the screen
#    And I tap "Show Simple"
#    And I tap "OK"
#    And I tap "Show OK-Cancel"
#    And I tap "Cancel"
#    And I tap "Show Customized"
#    And I tap "Button2"
#    And I scroll down
#    And I tap "Show Simple"
#    And I tap "OK"
#    And I tap "Show OK-Cancel"
#    And I tap "OK"
#    And I tap "Show Custom"
#    And I tap "Cancel"
