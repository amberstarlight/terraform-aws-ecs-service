resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_log_group ? 1 : 0
  name              = local.log_group_name
  skip_destroy      = var.skip_destroy
  retention_in_days = 30
  kms_key_id        = aws_kms_key.this[0].arn
}

resource "aws_kms_key" "this" {
  count               = var.create_log_group ? 1 : 0
  description         = "KMS key to encrypt logs for ${var.service_name}"
  key_usage           = "ENCRYPT_DECRYPT"
  enable_key_rotation = true
}

resource "aws_kms_key_policy" "this" {
  count  = var.create_log_group ? 1 : 0
  key_id = aws_kms_key.this[0].key_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "logs.${local.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*",
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${local.region}:${local.account_id}:log-group:${local.log_group_name}"
          }
        }
      }
    ]
  })
}
