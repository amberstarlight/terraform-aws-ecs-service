data "aws_iam_policy_document" "secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      data.aws_secretsmanager_secret.api_token.arn
    ]
  }
}

resource "aws_iam_policy" "secrets" {
  name   = "secrets-policy"
  policy = data.aws_iam_policy_document.secrets.json
}
