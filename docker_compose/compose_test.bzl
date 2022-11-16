load("//docker_compose:providers.bzl", "NetworkInfo", "ServiceInfo")

script = """#!/bin/bash

set -euo pipefail

{DOCKER_LOAD_IMAGES}

docker compose --file={DOCKER_COMPOSE_FILE} up \
    --abort-on-container-exit \
    --exit-code-from=test \
    --force-recreate

exit 0
"""

def _impl(ctx):
    if "test" not in ctx.attr.services.values():
        fail("The 'test' service must be defined for compose_test")

    docker_compose = {}

    # services
    image_tars = []
    docker_compose["services"] = {}
    for target, name in ctx.attr.services.items():
        service_info = target[ServiceInfo]
        docker_compose["services"][name] = {
            "image": service_info.image.name,
            "ports": service_info.ports,
            "networks": service_info.networks,
        }
        image_tar = ctx.actions.declare_file("{}.{}.tar".format(name, service_info.image.name))
        image_tars.append(image_tar)
        ctx.actions.symlink(
            target_file = service_info.image.tar,
            output = image_tar,
        )

    # networks
    docker_compose["networks"] = {}
    for service in docker_compose["services"].values():
        for network in service["networks"]:
            docker_compose["networks"][network] = {}
    for target, name in ctx.attr.networks.items():
        network_info = target[NetworkInfo]
        docker_compose["networks"][name] = {
            "external": network_info.external,
        }

    docker_compose_yml = ctx.actions.declare_file(ctx.label.name + ".yml")
    ctx.actions.write(
        output = docker_compose_yml,
        content = json.encode_indent(docker_compose, indent = "  "),
    )

    executable = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(
        content = script.format(
            DOCKER_LOAD_IMAGES = "\n".join(["docker load -i {}".format(tar.short_path) for tar in image_tars]),
            DOCKER_COMPOSE_FILE = docker_compose_yml.short_path,
        ),
        output = executable,
    )

    return [
        DefaultInfo(
            runfiles = ctx.runfiles(files = image_tars + [
                docker_compose_yml,
            ]),
            executable = executable,
        ),
    ]

compose_test = rule(
    implementation = _impl,
    attrs = {
        "services": attr.label_keyed_string_dict(allow_empty = False, allow_files = False, providers = [ServiceInfo]),
        "networks": attr.label_keyed_string_dict(allow_empty = True, allow_files = False, providers = [NetworkInfo]),
    },
    test = True,
)
