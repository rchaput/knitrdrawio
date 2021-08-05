#'
#' @import knitr
#'

# Loader/Unloader functions

# Add the drawio engine to the list of knitr engines, for using in Rmd
# documents, and the `cache` hook
.onLoad = function(libname,pkgname) {
    # Add engine
    knitr::knit_engines$set(drawio = drawio.engine)

    # Add hook
    knitr::opts_hooks$set(cache = hook.cache)
}

# Remove the drawio engine from the list of knitr engines, and the `cache` hook
.onUnload = function(libname,pkgname) {
    # Remove engine
    knitr::knit_engines$delete("drawio")

    # Replace hook by original
    knitr::opts_hooks$set(cache = old.hook)
}
