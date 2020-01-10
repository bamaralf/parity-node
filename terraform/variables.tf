variable "drive_letter" {
    description = "The EBS volumes are attached as /dev/xvd'<drive_letter>', ex.: /dev/xvdf. This variable set the value to complete the EBS target device."
    default     = "f"
}

variable "public_key" {
    description = "The public SSH key to be added on the AWS EC2 instance."
}
