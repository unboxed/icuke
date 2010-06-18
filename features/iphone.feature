Feature: iPhone integration tests
  In order to test my iphone application
  As a developer
  I want cucumber to be able to drive the simulator

  Background:
    Given "app/sdk3.1/UICatalog.xcodeproj" is loaded in the simulator with SDK 3.1

  Scenario: Scrolling up and down
    When I tap "Buttons"
    And I scroll down
    And I scroll up
    And I tap "Back"
    And I scroll down
    And I tap "Transitions"

  Scenario: Scrolling to a visible object
    When I scroll down to "Transitions"
    Then I should see "Transitions"

  Scenario: Pressing buttons
    When I tap "Buttons"
    And I tap "Gray"
    And I tap "Right pointing arrow"
    And I tap "Rounded"
    And I scroll down
    And I tap "More info"
    And I tap "Add contact"

  Scenario: Switches
    When I tap "Controls"
    And I tap "Standard switch"

  Scenario: Finding text
    When I tap "TextView"
    Then I should see "Now is the time for all good developers to come to serve their country."

  Scenario: Entering text
    When I tap "TextFields"
    And I type "symb0ls $!@ and spaces" in "Normal"
    Then I should see "symb0ls $!@ and spaces"
    When I type "cucumber for iphone" in "Rounded"
    And I should see "cucumber for iphone"
    And I type "secret" in "Secure"

  Scenario: Segment
    When I tap "Segment"
    And I tap "Check"
    And I tap "Search"
    And I tap "Tools"

  Scenario: Web
    When I tap "Web"
    And I tap "Clear text"
    And I type "http://google.com" in "URL entry"

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
    When I tap "Controls"
    And I drag from 258,285 to 319,285
    And I drag from 293,285 to 258,285
    And I drag from 244,439 to 319,439
    And I tap "Back"
    And I tap "Controls"
    And I select the "Standard Slider" slider and drag 50 pixels left
    And I select the "Standard Slider" slider and drag 20 pixels right
    And I select the "Standard Slider" slider and drag 40 pixels left
    And I select the "Standard Slider" slider and drag 70 pixels right
    And I move the "Standard Slider" slider to 50 percent
    And I move the "Standard Slider" slider to 25 percent
    And I move the "Standard Slider" slider to 0 percent
    And I move the "Standard Slider" slider to 75 percent
    And I move the "Standard Slider" slider to 100 percent
    And I move the "Standard Slider" slider to 50 percent
    And I tap "Back"
    And I scroll down
    And I tap "Toolbar"
    And I drag from 97,400 to 97,233
    And I tap "Back"

  Scenario: Alerts
    When I scroll down
    And I tap "Alerts"
