load("//docker_compose:compose.bzl", _compose = "compose")
load("//docker_compose:network.bzl", _network = "network")
load("//docker_compose:service.bzl", _service = "service")

compose = _compose
network = _network
service = _service
