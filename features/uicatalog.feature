Feature: iPhone integration tests
  In order to test my iphone application
  As a developer
  I want cucumber to be able to drive the simulator

  Scenario: Pressing buttons
    Given "app/sdk3/UICatalog.xcodeproj" is loaded in the simulator with SDK 3.2
    When I tap "Buttons"
    And I tap "Gray"

  Scenario: Switches and sliders
    Given "app/sdk3/UICatalog.xcodeproj" is loaded in the simulator with SDK 3.2
    When I tap "Controls"
    And I tap "Standard switch"

  Scenario: Entering text
    Given "app/sdk3/UICatalog.xcodeproj" is loaded in the simulator with SDK 3.2
    When I tap "TextFields"
    And I type "A string with symb0ls $!@ and spaces in it" in "Normal"
    Then I should see "A string with symb0ls $!@ and spaces in it"
