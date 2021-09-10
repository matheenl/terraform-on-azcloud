
variable "prefix" {
  type        = string
  description = "Prefix for all resources"
  default     = "Terra"

}

variable "tags" {
  type        = map(any)
  description = "Tags for all reosurces"
  default = {
    Learning     = "TF-Exam"
    Cost         = "Free"
    Subscription = "VisualStudio Enterprise MSDN"
  }

}

variable "environment" {
  type        = string
  description = "Type of Environment"
  default     = "Test"

}
variable "location" {
  type        = string
  description = "Location of Resources"
  default     = "WestEurope"

}

variable "fe-rg-name" {
  type        = string
  description = "Name of the FrontEnd Resource Group"
  default     = "rg-fe"

}
variable "be-rg-name" {
default = "rg-be"
type = string
}

variable "admin-password" {
  type        = string
  sensitive = true
  description = "Admin Password"
  default     = "adminadmin123!"

}

variable "admin-username" {
  type        = string
  sensitive = true
  description = "Admin user name"
  default     = "adminuser"

}

variable "webvm-name" {
default = "webvm01"
type = string
}
variable "jboxvm-name" {
default = "jboxvm01"
type = string
}
