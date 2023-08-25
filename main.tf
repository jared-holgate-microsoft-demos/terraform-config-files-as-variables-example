terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.8.0"
    }
  }
}

locals {
  const_both           = "both"
  const_yaml           = "yaml"
  const_json           = "json"
}

locals {
  file_extension_match = "**/*.${var.config_file_type == local.const_both ? "{${local.const_yaml},${local.const_json}}" : var.config_file_type}"

  raw_data = merge({ for filepath in fileset(var.config_file_folder_path, local.file_extension_match) :
    basename(dirname(filepath)) => (endswith(filepath, ".${local.const_yaml}") ?
      yamldecode(file("${var.config_file_folder_path}/${filepath}")) :
      jsondecode(file("${var.config_file_folder_path}/${filepath}")))... #NOTE: This elipsis enables multiple files under the same project folder
  })

  projects = { for project in keys(local.raw_data) : project => project }

  groups = { for flat_groups in flatten([for project, base_objects in local.raw_data :
    [for base_object in base_objects :
      [for group in base_object.groups :
        {
          project_name = project
          group_name   = group.name
          members      = group.members
        }
      ]
    ]
  ]) : "${flat_groups.project_name}_${flat_groups.group_name}" => flat_groups }

  membership = { for flat_membership in flatten([for project, base_objects in local.raw_data :
    [for base_object in base_objects :
      [for group in base_object.groups :
        [for member in group.members :
          {
            project_name = project
            group_name   = group.name
            member_name  = member
          }
        ]
      ]
    ]
  ]) : "${flat_membership.project_name}_${flat_membership.group_name}_${flat_membership.member_name}" => flat_membership }
}

/*
data "azuredevops_project" "example" {
  for_each = local.projects
  name     = each.key
}

resource "azuredevops_group" "example" {
  for_each     = local.groups
  scope        = data.azuredevops_project.example[each.value.project_name].id
  display_name = each.value.group_name
  description  = each.value.group_name
}

resource "azuredevops_group_membership" "example" {
  for_each = local.membership
  group = azuredevops_group.example[each.value.group_name].descriptor
  members = [
    each.value.member_name
  ]
  mode = "add"
} 
*/