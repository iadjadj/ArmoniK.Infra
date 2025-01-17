locals {
  tags = merge(var.tags, { module = "amazon-mq" })
  subnet_ids = (var.mq.deployment_mode == "SINGLE_INSTANCE" ? [var.vpc.subnet_ids[0]] : [
    var.vpc.subnet_ids[0],
    var.vpc.subnet_ids[1]
  ])
  username = (var.user.username != "" ? var.user.username : random_string.user.result)
  password = (var.user.password != "" ? var.user.password : random_password.password.result)
}
