load("//docker_compose:providers.bzl", "ServiceInfo")

def _short_path_to_image_name(short_path):
    return "bazel/{}".format(":".join(short_path.rsplit("/", 1)))[:-4]

def _impl(ctx):
    # image
    image_name = _short_path_to_image_name(ctx.attr.image.files.to_list()[0].short_path)
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
            configs = ctx.attr.configs,
            networks = ctx.attr.networks,
            ports = ctx.attr.ports,
            secrets = ctx.attr.secrets,
            volumes = ctx.attr.volumes,
        ),
    ]

service = rule(
    implementation = _impl,
    attrs = {
        "image": attr.label(mandatory = True, allow_files = True),
        "configs": attr.string_list(mandatory = False, default = []),
        "networks": attr.string_list(mandatory = False, default = []),
        "ports": attr.string_list(mandatory = False, default = []),
        "secrets": attr.string_list(mandatory = False, default = []),
        "volumes": attr.string_list(mandatory = False, default = []),
    },
)
