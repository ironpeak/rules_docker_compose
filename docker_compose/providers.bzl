NetworkInfo = provider(
    fields = [
        "external",
    ],
)

ServiceInfo = provider(
    fields = [
        "image",
        "ports",
        "environment",
        "networks",
    ],
)
