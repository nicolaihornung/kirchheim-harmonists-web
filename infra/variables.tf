variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID for kirchheim-harmonists.de"
}

variable "account_id" {
  type        = string
  description = "Cloudflare Account ID"
}

variable "email_worker_name" {
  type        = string
  description = "Name of the deployed email fan-out Worker"
  default     = "kirchheim-harmonists-email-router"
}
