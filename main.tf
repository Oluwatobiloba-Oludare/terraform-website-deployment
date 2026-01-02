resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname

  tags = {
    Name        = "Mybucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "sample" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "sample" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.mybucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.mybucket.arn}/*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.sample
  ]
}


resource "aws_s3_object" "terraform_project1" {
  for_each = {
    "index.html"  = "text/html"
    "error.html"  = "text/html"
    "profile.png" = "image/png"
  }

  bucket       = var.bucketname
  key          = each.key
  source       = each.key
  content_type = each.value
}


resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [ aws_s3_bucket_policy.public_read ]

}
