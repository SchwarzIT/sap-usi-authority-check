<!-- Links used on this page (Declaration) -->
[CONTRIBUTING]:   ./docs/CONTRIBUTING.md
[SYSTEM_SETUP]:   https://github.com/SchwarzIT/sap-usi#getting-started




[![SIT](https://img.shields.io/badge/SIT-About%20us-%236e1e6e)](https://it.schwarz/en)
[![USI](https://img.shields.io/badge/USI-More%20Software-blue)](https://github.com/SchwarzIT/sap-usi)

# USI Authority Check
## Purpose
This repository contains the helper class /USI/CL_AUTH that checks, if the user is authorized for the current transaction.

The class is very simple and would not be worth sharing, but according to our internal development guidelines, it must be used in all USI reports to secure them against unauthorized access.

Because of this rule, many of our developments depend on this class.

## Installation Guide
Before starting, the system must be [set up for USI][SYSTEM_SETUP].   
This component has no dependencies and no special authorizations are required.

## How to contribute
Please check our [contribution guidelines][CONTRIBUTING] to learn more about this topic.
