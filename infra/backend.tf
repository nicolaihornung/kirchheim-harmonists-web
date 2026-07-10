terraform {
  # State lives in Cloudflare R2 via the S3-compatible backend.
  #
  # Only the static, non-secret R2 flags live here. Account-specific values
  # (bucket, key, endpoints) are supplied at init time from a git-ignored
  # backend.hcl:  terraform init -backend-config=backend.hcl
  #
  # The R2 access key id / secret are read from the standard AWS env vars
  # (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY) — see README.md.
  backend "s3" {
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    use_lockfile                = true # native state locking (Terraform >= 1.10); no DynamoDB
  }
}
