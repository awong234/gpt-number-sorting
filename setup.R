install.packages("pak")

pak::pkg_install(c(
    "ellmer",
    "dplyr",
    "xfun",
    "keyring",
    "glue",
    "knitr",
    "import",
    "withr",
    "memoise"
))

# keyring::key_set("openai", "token")
