output "url" {
  value = "http://${aws_s3_bucket_website_configuration.this.website_endpoint}"
}