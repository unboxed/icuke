Feature: iPhone integration tests
  In order to test my iphone application
  As a developer
  I want cucumber to be able to drive the simulator

  Background:
    Given "app/sdk4.0/UICatalog.xcodeproj" is loaded in the simulator with SDK 4.0

  Scenario: Pressing buttons
    When I tap "Buttons"
    And I tap "Gray"

  Scenario: Switches and sliders
    When I tap "Controls"
    And I tap "Standard switch"

  Scenario: Entering text
    When I tap "TextFields"
    And I type "symb0ls $!@ and spaces" in "Normal"
    Then I should see "symb0ls $!@ and spaces"
