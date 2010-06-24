Feature: iPhone integration tests
  In order to test my iphone application
  As a developer
  I want cucumber to be able to drive the simulator

  Background:
    Given "app/Universal.xcodeproj" is loaded in the iphone simulator

  Scenario: Scrolling
    When I tap "Show Test Modal"
    Then I should see "Lorem ipsum dolor"
    But I should not see "Fusce sem nisi"
    When I scroll down to "Fusce sem nisi"
    Then I should see "Fusce sem nisi"
    But I should not see "Lorem ipsum dolor"
