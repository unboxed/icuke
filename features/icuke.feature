Feature: Developer tests an application
  In order to test my application
  As a developer
  I want to use some shiney cucumber steps
  
  Scenario: Developer basks in iPhone step goodness
    Given "app/iCuke/build/Debug-iphonesimulator/iCuke.app" is loaded in the simulator
    Then I should see "iCuke"
    When I press "About"
    Then I should see "About"
    When I press "Done"
    Then I should see "iCuke"
