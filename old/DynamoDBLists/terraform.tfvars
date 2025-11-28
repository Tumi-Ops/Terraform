name           = "ListsTable"
billing_mode   = "PROVISIONED"
read_capacity  = 20
write_capacity = 20
hash_key       = "user_email"
range_key      = "list_name"
