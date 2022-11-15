load("//docker_compose:providers.bzl", "ServiceInfo")

script = """#!/bin/bash

echo "Hello World!"
"""

def _impl(ctx):
    docker_compose = {
        "services": {},
        "configs": {},
        "networks": {},
        "secrets": {},
        "volumes": {},
    }

    for target, name in ctx.attr.services.items():
        service_info = target[ServiceInfo]
        docker_compose["services"][name] = {
            "image": service_info.image.name,
        }

    executable = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        content = script,
        output = executable,
    )

    print(json.encode(docker_compose))

    return [
        DefaultInfo(
            files = depset([]),
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
