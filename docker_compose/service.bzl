load("//docker_compose:providers.bzl", "ServiceInfo")

def _impl(ctx):
    # image
    image_name = ctx.attr.repository
    image_tar = ctx.actions.declare_file(ctx.label.name + ".image")
    ctx.actions.symlink(
        target_file = ctx.attr.image.files.to_list()[0],
        output = image_tar,
    )

    return [
        ServiceInfo(
            image = struct(
                name = image_name,
                tar = image_tar,
            ),
            ports = ctx.attr.ports,
            environment = ctx.attr.environment,
            networks = ctx.attr.networks,
        ),
    ]

service = rule(
    implementation = _impl,
    attrs = {
        "image": attr.label(mandatory = True, allow_files = True),
        "repository": attr.string(mandatory = True),
        "ports": attr.string_list(mandatory = False, default = []),
        "environment": attr.string_dict(mandatory = False, allow_empty = True, default = {}),
        "networks": attr.string_list(mandatory = False, default = []),
    },
)
