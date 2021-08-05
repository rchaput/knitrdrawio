#' Hook function for caching drawio chunks
#'
#' This hook is registered with \emph{knitr} to be automatically called when
#' the user sets the "\code{cache}" chunk option.
#' If the chunk's engine is "\code{drawio}", this function will compute a MD5
#' checksum of the specified source file (the "\code{src}" chunk option) and
#' add it to the chunk options.
#' As \emph{knitr} uses the chunk options to cache the result of a chunk,
#' this means that the chunk will not be re-executed as long as the MD5 stays
#' the same, i.e., the source diagram is not modified.
#'
#' It should not be called manually by the user, and is registered when the
#' package is loaded.
#'
#' If a previous hook was registered for the \code{cache} option, this hook
#' is first stored so that our hook can call it when executed.
#'
#' @param options The chunk options
#'
#' @return The chunk options. They are updated with an additional value
#' (the source file's checksum), indexed by \code{cache.src.md5}, if the
#' engine is set to \code{drawio} and the \code{cache} option is set to
#' \code{TRUE}.
#'
#' @export
#'
hook.cache <- function(options) {

    if (!is.null(old.hook)) {
        options <- old.hook(options)
    }
    if (!isTRUE(options$cache) || options$engine != "drawio") {
        # Ignore this chunk
        return(options)
    }

    # Compute the MD5 of the source diagram and store it in the options
    # Knitr uses these options to check if the chunk should be re-executed
    # (thus, if the MD5 changes, the chunk is re-executed)
    options$cache.src.md5 <- tools::md5sum(options$src)

    return(options)
}

# Store the previous hook so we can call it
old.hook <- knitr::opts_hooks$get("cache")
