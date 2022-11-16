load("//docker_compose:providers.bzl", "NetworkInfo")

def _impl(ctx):
    return [
        NetworkInfo(
            external = ctx.attr.external,
        ),
    ]

network = rule(
    implementation = _impl,
    attrs = {
        "external": attr.bool(default = False),
    },
)
