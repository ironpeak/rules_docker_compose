load("//docker_compose:providers.bzl", "ServiceInfo")

script = """#!/bin/bash

{DOCKER_LOAD_IMAGES}

docker compose --file={DOCKER_COMPOSE_FILE} up
"""

def _impl(ctx):
    docker_compose = {
        "services": {},
        "configs": {},
        "networks": {},
        "secrets": {},
        "volumes": {},
    }

    image_tars = []
    for target, name in ctx.attr.services.items():
        service_info = target[ServiceInfo]
        docker_compose["services"][name] = {
            "image": service_info.image.name,
            "configs": service_info.configs,
            "networks": service_info.networks,
            "ports": service_info.ports,
            "secrets": service_info.secrets,
            "volumes": service_info.volumes,
        }
        image_tar = ctx.actions.declare_file("{}.{}.tar".format(name, service_info.image.name))
        image_tars.append(image_tar)
        ctx.actions.symlink(
            target_file = service_info.image.tar,
            output = image_tar,
        )

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

compose = rule(
    implementation = _impl,
    attrs = {
        "services": attr.label_keyed_string_dict(allow_empty = False, allow_files = False, providers = [ServiceInfo]),
        "configs": attr.label_list(mandatory = False, default = [], allow_files = False),
        "networks": attr.label_list(mandatory = False, default = [], allow_files = False),
        "secrets": attr.label_list(mandatory = False, default = [], allow_files = False),
        "volumes": attr.label_list(mandatory = False, default = [], allow_files = False),
    },
    executable = True,
)
