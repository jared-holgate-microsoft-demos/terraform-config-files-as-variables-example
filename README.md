# Using config files as variables for Terraform

This example shows how you can use json, yaml or a combination of as configuration input into Terraform.

## How to use it
1. Clone the repo
1. Open CLI in the root folder
1. Run `terraform init`
1. Run `terrafrom plan`
1. Observe the outputs

## What it does
1. Consumes json and yaml files from a config folder structure and converts them to Terraform objects
1. Manipulates the raw objects into `projects`, `groups` and `memberships` local variable maps which flatten them for easier use
1. The commented out code shows how those local maps could be use in `for_each` attributes of Azure DevOps group resources
