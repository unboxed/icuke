Feature: iPhone integration tests
  In order to test my iphone application
  As a developer
  I want cucumber to be able to drive the simulator

  Background:
    Given "app/UICatalog.xcodeproj" is loaded in the simulator

  Scenario: Pressing buttons
    When I tap "Buttons"
    And I tap "Gray"

  Scenario: Switches and sliders
    When I tap "Controls"
    And I tap "Standard switch"

  Scenario: Entering text
    When I tap "TextFields"
    And I type "A string with symb0ls $!@ and spaces in it" in "Normal"
    Then I should see "A string with symb0ls $!@ and spaces in it"
