resource "aws_sqs_queue" "crypt" {
  name                       = "crypt_${local.vpc_shortname}"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 345600
}

resource "aws_sqs_queue_policy" "crypt_policy" {
  queue_url = aws_sqs_queue.crypt.id
  policy    = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [{
		"Sid": "Allowcrypt",
		"Effect": "Allow",
		"Principal": {
			"AWS": "arn:aws:iam::472882997329:user/service_crypt_qa02"
		},
		"Action": ["SQS:GetQueueAttributes","SQS:DeleteMessage", "SQS:ReceiveMessage", "SQS:SendMessage"],
		"Resource": "${aws_sqs_queue.crypt.arn}"
	},
	{
		"Sid": "AllowEverybody",
		"Effect": "Allow",
		"Principal": "*",
		"Action": "SQS:SendMessage",
		"Resource": "${aws_sqs_queue.crypt.arn}",
		"Condition": {
			"ArnLike": {
				"aws:SourceArn": "arn:aws:s3:*:*:narvar-dmz-qa02"
			}
		}
	},
	{
		"Sid": "AllowDataPlatformGroup",
		"Effect": "Allow",
		"Principal": {
			"AWS": [
	          "arn:aws:iam::${local.account_id}:user/elliott.feng@narvar.com",
	          "arn:aws:iam::${local.account_id}:user/ketan@narvar.com"
        	]
		},
		"Action": ["SQS:GetQueueAttributes","SQS:DeleteMessage", "SQS:ReceiveMessage", "SQS:GetQueueUrl"],
		"Resource": "${aws_sqs_queue.crypt.arn}"
	}]
}
POLICY

}

