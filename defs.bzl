load("//docker_compose:compose.bzl", _compose = "compose")
load("//docker_compose:compose_test.bzl", _compose_test = "compose_test")
load("//docker_compose:network.bzl", _network = "network")
load("//docker_compose:service.bzl", _service = "service")

compose = _compose
compose_test = _compose_test
network = _network
service = _service
