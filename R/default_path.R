#' Find the Drawio executable
#'
#' This function tries to find the path to a **drawio** executable, assuming
#' a default installation, in a well-known location, depending on the OS.
#'
#' @section Overriding the default path:
#'
#' This function is only used to return the \emph{default} path, if
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
#' @md
#'
drawio.default.path <- function() {
    os <- get.os.type()

    if (os == "Darwin") {
        path <- drawio.default.path.darwin()
    } else if (os == "Linux" || os == "unix") {
        path <- drawio.default.path.linux()
    } else if (os == "Windows") {
        path <- drawio.default.path.windows()
    } else {
        stop("Your OS (", os, ") was not recognized. ",
             "Please set your custom location by using the `engine.path` ",
             "chunk option. See the ?knitrdrawio::drawio.default.path ",
             "documentation for more details.")
    }

    if (is.null(path)) {
        # Returning NULL could create problems later (e.g., trying to execute
        # the command line might execute another, unwanted program).
        # So we definitely stop the execution.
        stop("Could not find a path to drawio on your OS (", os, ").",
             "Please make sure that drawio is installed, and set your ",
             "custom location by using the `engine.path` chunk option. ",
             "See the ?knitrdrawio::drawio.default.path documentation ",
             "for more details.")
    } else if (!file.exists(path)) {
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


#' @describeIn drawio.default.path Find default path on Linux
#'
#' @section Linux:
#'
#' On *Linux*, the executable is first searched in the directories specified
#' in the \code{PATH} environment variable, through the
#' \code{\link[base]{Sys.which}} function.
#'
#' If the executable cannot be found in the \code{PATH}, we search
#' in a few well-known (common) locations:
#'
#' * \code{/bin} ;
#' * \code{/usr/bin} ;
#' * \code{/opt/drawio}.
#'
#' @md
drawio.default.path.linux <- function () {
    # First, we try with `Sys.which` if the `drawio` executable can be found
    # in the PATH.
    path <- Sys.which("drawio")[[1]]
    if (file.exists(path)) {
        return(path)
    }

    # Same, but with the `draw.io` name.
    path <- Sys.which("draw.io")[[1]]
    if (file.exists(path)) {
        return(path)
    }

    # We cannot find it on the PATH, let's try for some common locations.
    paths <- c("/bin/drawio",
               "/bin/draw.io",
               "/usr/bin/drawio",
               "/usr/bin/draw.io",
               "/usr/local/bin/drawio",
               "/usr/local/bin/draw.io",
               "/opt/drawio/drawio",
               "/opt/drawio/draw.io"
    )

    for (path in paths) {
        if (file.exists(path)) {
            return(path)
        }
    }

    # We have not found the executable anywhere, return NULL to signal it.
    NULL
}


#' @describeIn drawio.default.path Find default path on Darwin (Mac OS X)
#'
#' @section MacOS:
#'
#' On *Mac OS X* (\code{Darwin}), the executable is first searched in
#' the directories specified in the \code{PATH} environment variable,
#' through the \code{\link[base]{Sys.which}} function.
#'
#' If the executable cannot be found in the \code{PATH}, we search
#' in a few well-known (common) locations:
#'
#' * \code{/Applications} ;
#' * \code{~/Applications} ;
#' * \code{~/bin} ;
#' * \code{/bin} ;
#' * \code{/usr/bin} ;
#' * \code{/usr/local/bin} ;
#' * \code{/opt/drawio}.
#'
#' @md
drawio.default.path.darwin <- function () {
    # First, we try with `Sys.which` if the `drawio` executable can be found
    # in the PATH.
    path <- Sys.which("drawio")[[1]]
    if (file.exists(path)) {
        return(path)
    }

    # Same, but with the `draw.io` name.
    path <- Sys.which("draw.io")[[1]]
    if (file.exists(path)) {
        return(path)
    }

    # We cannot find it on the PATH, let's try for some common locations.
    paths <- c("/Applications/draw.io.app/Contents/MacOS/draw.io",
               "~/Applications/draw.io.app/Contents/MacOS/draw.io",
               "~/bin/drawio",
               "~/bin/draw.io",
               "/bin/drawio",
               "/bin/draw.io",
               "/usr/bin/drawio",
               "/usr/bin/draw.io",
               "/usr/local/bin/drawio",
               "/usr/local/bin/draw.io",
               "/opt/drawio/drawio",
               "/opt/drawio/draw.io"
    )

    for (path in paths) {
        if (file.exists(path)) {
            return(path)
        }
    }

    # We have not found the executable anywhere, return NULL to signal it.
    NULL
}


#' @describeIn drawio.default.path Find default path on Windows
#'
#' @section Windows:
#'
#' On *Windows*, the executable is first searched in the directories specified
#' in the \code{PATH} environment variable, through the
#' \code{\link[base]{Sys.which}} function.
#'
#' @md
drawio.default.path.windows <- function () {
    # First, we try with `Sys.which` if the `drawio` executable can be found
    # in the PATH.
    path <- Sys.which("drawio.exe")[[1]]
    if (file.exists(path)) {
        return(path)
    }

    # Same, but with the `draw.io` name.
    path <- Sys.which("draw.io.exe")[[1]]
    if (file.exists(path)) {
        return(path)
    }

    # TODO: find some common installation paths on Windows
    #  maybe look for Electron-builder default path?

    # We have not found the executable anywhere, return NULL to signal it.
    NULL
}
