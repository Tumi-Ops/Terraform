variable "name" {
  description = "Unique within a region name of the table."
  type        = string
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity."
  type        = string
}

variable "read_capacity" {
  description = "Number of read units for this table"
  type        = number
}

variable "write_capacity" {
  description = "Number of write units for this table"
  type        = number
}

variable "hash_key" {
  description = "Attribute to use as the hash (partition) key"
  type        = string
}

variable "range_key" {
  description = "Attribute to use as the range (sort) key"
  type        = string
}