
variable "env" {
  description = "Environment"
  #default     = "test" - This is controlled using terraform.tfvars
}
variable "prefix" {
  description = "Prefix for all resources that will be created"
  default     = "tf"
}
variable "location" {
  description = "Location of Resources"
  default     = "WestEurope"
}
variable "vm-size" {
  description = "Size of the VM in a list which can be indexed as var.vm-size[0]"
  default = [
    "Standard_B2s",
    "Standard_B1s"
  ]
}
variable "vm-image" {
  description = "VM source Image Reference"
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-smalldisk"
    version   = "latest"
  }
}

variable "tags" {
  description = "Tags for all reosurces"
  default = {
    Learning     = "TF-Exam"
    Cost         = "Free"
    Subscription = "VisualStudio Enterprise MSDN"
  }
}

variable "admin-password" {
  sensitive   = true
  description = "Admin Password"
  default     = "adminadmin123!"
}

variable "admin-username" {
  sensitive   = true
  description = "Admin user name"
  default     = "adminuser"
}

/*
variable "fe-rg-name" {  
  description = "Name of the FrontEnd Resource Group"
  default     = "rg-fe"
}
variable "be-rg-name" {
  default = "rg-be"
  type    = string
}
variable "webvm-name" {
  default = "webvm01"
  type    = string
}
variable "jboxvm-name" {
  default = "jboxvm01"
  type    = string
}
*/
