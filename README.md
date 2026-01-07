<!-- Links used on this page (Declaration) -->
[CONTRIBUTING]:   ./docs/CONTRIBUTING.md



[![SIT](https://img.shields.io/badge/SIT-About%20us-%236e1e6e)](https://it.schwarz/en)
[![USI](https://img.shields.io/badge/USI-More%20Software-blue)](https://github.com/SchwarzIT/sap-usi)

# USI Authority Check
## Purpose
This repository contains the helper class /USI/CL_AUTH that checks, if the user is authorized for the current transaction.

The class is very simple and would not be worth sharing, but according to our internal development guidelines, it must be used in all USI reports to secure them against unauthorized access.

Because of this rule, many of our developments depend on this class.

## Installation Guide
This component has no dependencies and no special authorizations are required.

It is recommended to create the repository using the follwing settings.
<img width="956" height="671" alt="image" src="https://github.com/user-attachments/assets/7347ed9f-e353-4622-a9d4-24c4cae59d3c" />

| Field              | Value                                                |
|--------------------|------------------------------------------------------|
| Git Repository URL | https://github.com/SchwarzIT/sap-usi-authority-check |
| Package            | /USI/AUTH_MAIN                                       |
| Display Name       | USI Authority Check                                  |
| Labels             | SchwarzIT                                            |

**Note**: The package name **must** start with ``/USI/`` to avoid issues when pulling the repository.

## How to contribute
Please check our [contribution guidelines][CONTRIBUTING] to learn more about this topic.
