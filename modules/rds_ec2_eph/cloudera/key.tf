resource "aws_key_pair" "mykey" {
#  count = "${var.sg_count}"
  key_name = "${var.environment}-mykey"
  public_key = "${file("${var.path_to_pubkey}")}"
}
