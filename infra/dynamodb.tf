# infra/dynamodb.tf

resource "aws_dynamodb_table" "user_session_context" {
  name         = "UserSessionContext"
  billing_mode = "PAY_PER_REQUEST" # On-Demand pricing: $0 when idle
  hash_key     = "SessionId"       # Partition Key

  # Explicitly declare the schema type for the Partition Key
  attribute {
    name = "SessionId"
    type = "S" # S stands for String
  }

  # Time to Live (TTL) automatically deletes old sessions after they expire
  ttl {
    attribute_name = "ExpirationTime"
    enabled        = true
  }
}