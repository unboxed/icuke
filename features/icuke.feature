Feature: Developer tests an application
  In order to test my application
  As a developer
  I want to use some shiney cucumber steps
  
  Background:
    Given "iCuke" from "app/iCuke/iCuke.xcodeproj" is loaded in the simulator
  
  Scenario: Press buttons and see stuff
    Then I should see "iCuke"
    When I tap "About"
    Then I should see "About"
    When I tap "Done"
    Then I should see "iCuke"

  Scenario: Type into a textfield
    Then I type "fOo@Oo" in "Input"
