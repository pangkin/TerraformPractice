# Codebuild 신뢰할 수 있는 엔티티
data "aws_iam_policy_document" "codebuild_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Codebuild 역할 정책
data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/codebuild/${var.project_name}-codebuild",
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/codebuild/${var.project_name}-codebuild:*"
    ]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::${var.project_name}-bucket-*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]

    resources = [
      "arn:aws:codebuild:${var.aws_region}:${var.account_id}:report-group/${var.project_name}-*"
    ]
  }
}
