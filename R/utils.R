#' Default path to the Drawio executable
#'
#' This function returns a (supposedly) sane default for the path to the
#' \code{drawio} executable, depending on the current OS.
#'
#' On MacOS (\code{Darwin}), this executable should be located in the
#' \emph{Applications} directory:
#' \preformatted{/Applications/draw.io.app/Contents/MacOS/draw.io}
#'
#' On Linux, the executable is assumed to be located at:
#' \preformatted{/usr/bin/draw.io}
#' Note that this path is mostly dependent on the distribution you use,
#' and the package you installed. On ArchLinux, the \code{/usr/bin} path
#' should work, but it might be in \code{/bin} in other distributions.
#'
#' On Windows, it is assumed that the executable is available with
#' \preformatted{drawio.exe}
#'
#' @note This function is only used to return the \emph{default} path, if
#' no specific path is given by the user. If, on your machine, \code{drawio}
#' is not available at the default path, or if the OS could not be successfully
#' identified, please specify your custom location by using the
#' \code{engine.path} option.
#'
#' This option can be set in two manners. Either locally, for a single chunk,
#' by setting it in the code chunk header:
#' \preformatted{\{drawio mylabel, engine.path = "/path/to/drawio"\}}
#' Or globally, for all chunks, at the beginning of the RMardown document.
#' Note that, in this case, you should specify a list of engines (in case you
#' use other engines, such as \emph{Python} or \emph{Ruby}):
#' \preformatted{knitr::opts_chunks$set(engine.path = list(
#'   drawio = "/path/to/drawio",
#'   # Set here your other engines (if necessary)
#'   python = "/path/to/python",
#' ))}
#'
#' @importFrom utils file_test
#' @export
#'
drawio.default.path <- function() {
    # See https://www.r-bloggers.com/2015/06/identifying-the-os-from-r/
    sysinfo <- Sys.info()
    if (!is.null(sysinfo)) {
        os <- sysinfo['sysname']
    } else {
        os <- .Platform$OS.type
    }

    path <- switch(
        os,
        "Darwin" = "/Applications/draw.io.app/Contents/MacOS/draw.io",
        "Linux" = "/usr/bin/draw.io",
        "Windows" = "drawio.exe"
    )

    if (is.null(path)) {
        # Returning NULL could create problems later (e.g., trying to execute
        # the command line might execute another, unwanted program).
        # So we definitely stop the execution.
        stop("Your OS (", os, ") was not recognized. ",
             "Please set your custom location by using the `engine.path` ",
             "chunk option. See the ?knitrdrawio::drawio.default.path ",
             "documentation for more details.")
    }
    if (!file.exists(path)) {
        # Even if the path does not exist, we simply emit a warning here.
        # Just in case the command line might still work (e.g., if the
        # current working dir was not correctly set and the path is relative...)
        # and we do not want to block the user. The worse that could happen
        # would be to execute a non-existing file. The `system` call will
        # emit its own error in this case.
        warning("The default drawio path (", path, ") does not exist. ",
                "Please set your custom location by using the `engine.path` ",
                "chunk option. See the ?knitrdrawio::drawio.default.path ",
                "documentation for more details.")
    } else if (!file_test("-x", path)) {
        # Same as the previous `if`: just in case it might still work, we
        # only emit a warning.
        warning("The default drawio path (", path, ") is not executable. ",
                "Please set your custom location by using the `engine.path` ",
                "chunk option. See the ?knitrdrawio::drawio.default.path ",
                "documentation for more details.")
    }

    return(path)
}
