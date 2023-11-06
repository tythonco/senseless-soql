# Senseless SOQL

This project is meant to accompany the Tython blog post [*Senseless SOQL*](https://tython.co/salesforce/soql/2023/11/03/senseless-soql.html)

## Setup

1. Run `sf project deploy start -d force-app/main -o [YourOrgAliasOrUsername]` to bring in all necessary metadata.

2. Run `sf org assign permset -n SenselessSOQL -o [YourOrgAliasOrUsername]` to assign the project permission set to your user.

## Test

1. Run `sf apex run -f anonApex.apex -o [YourOrgAliasOrUsername] > anonApex.log` to see output from an Anonymous Apex context

2. In Salesforce navigate to `SenselessSOQL (LWC)` from the App Launcher to see output from a LWC context

3. Note that SOQL returns different values based on context AND applies unidirectional SOQL automagic in the LWC context!