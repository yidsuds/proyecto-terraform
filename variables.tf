variable "project"{
    description = "ContaApp"
    default = "otd"
}

variable "environment"{
    description = "environment to release"
    default = "dev"
}

variable "location"{
    description = "Azure region"
    default = "East US 2"
}

variable "tags"{
    description = "all tags"
    default ={
        environment = "dev"
        project     = "otd"
        created_by  = "terraform"
    }
}

variable "password" {
  description = "sqlserver password"
  type = string
  sensitive = true
  
}