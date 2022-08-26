#' Drawio engine for knitr
#'
#' This function is called by \emph{knitr} when a code chunk's engine is set
#' to \code{drawio}.
#' This engine uses the \emph{draw.io} software to export diagrams to images,
#' and outputs the image into the RMarkdown document.
#'
#' This function should normally not be used directly by the user, but rather
#' called by \emph{knitr} to process chunks.
#'
#' It is recommended to set the \code{label} chunk option with a meaningful
#' value, as it is used to name the resulting image in the file system.
#'
#' For a list of accepted options to control the export process, please see
#' \code{\link{parse.options}}.
#'
#' Two additional options are used in this function:
#' \describe{
#'   \item{eval}{If set to \code{FALSE}, the engine will not execute the
#'   code chunk. The diagram will neither be exported nor rendered in the
#'   document. (Default: \code{TRUE})}
#'
#'   \item{include}{If set to \code{FALSE}, the engine will execute the
#'   code chunk (the diagram will therefore be exported), but the result will
#'   not be rendered in the document. This is useful if you want to
#'   automatically export a diagram but manually use it. (Default: \code{TRUE})}
#' }
#'
#' @param options The chunk options. Please refer to the official \emph{knitr}
#' documentation for more details on these. Several important options for
#' this package are also described in the documentation of
#' \code{\link{parse.options}}
#'
#' @section Examples:
#'
#' In a RMarkdown document, type out the following chunks.
#'
#' Simple chunk with a label ("my-diag1"), and a source file ("diag1.drawio"):
#' \preformatted{
#' ```{drawio my-diag1, src="diag1.drawio"}
#' ```
#' }
#'
#' Setting the output format:
#' \preformatted{
#' ```{drawio my-diag2, src="diag2.drawio", format="pdf"}
#' ```
#' }
#'
#' A few more options, not cropping the result (i.e., the image has the same
#' size as the diagram), using a transparent background, and only exporting
#' the 4th page of the diagram:
#' \preformatted{
#' ```{drawio my-diag3, src="diag3.drawio", format="pdf", crop=FALSE, transparent=TRUE, page.index=4}
#' ```
#' }
#'
#' Setting the options manually with \code{engine.opts}:
#' \preformatted{
#' ```{drawio my-diag4, src="diag4.drawio", engine.opts="--embed-diagram --transparent", format="pdf"}
#' ```
#' }
#'
#' @export
#'
drawio.engine <- function(options) {

    if (!options$eval) {
        # Do nothing
        return()
    }

    # Parse the options to get the draw.io command line and the output path
    command <- parse.options(options)

    # Check if we are in a headless environment. If the global option is TRUE,
    # assume that we are, without checking. If FALSE, assume we are not.
    # If `null` (by default) or not a logical value, we check.
    headless <- getOption("knitrdrawio.headless")
    if (!is.logical(headless)) headless <- is.headless.env()
    if (isTRUE(headless)) {
        # We are in a headless (no graphical server) environment.
        # Draw.io requires one to work, so we have to use a virtual
        # server, such as `xvfb`, as described in the official repository
        # https://github.com/jgraph/drawio-desktop/issues/146
        command <- wrap.xvfb(command)
    }

    # Execute the command ; draw.io always returns 0, so we need to capture
    # stderr to detect errors. When `stderr` is TRUE, `stdout` needs to be TRUE.
    res <- system2(command$exe, args = command$args, stdout = TRUE, stderr = TRUE)

    # Detect and handle errors
    errors <- detect.errors(res)
    if (!is.null(errors)) {
        # draw.io reported an error in the stderr/stdout. We decide whether to
        # stop, skip, or continue. Default is to `stop`.
        on.error <- match.arg(options$on.error, c("stop", "skip", "continue"))
        if (on.error == "stop") {
            # Raise an error now and stop execution.
            # Knitr would probably raise one anyway, stopping now is more
            # informative for the user.
            drawio_error$raise(errors, abort = TRUE)
        } else if (on.error == "skip") {
            # Raise a warning to inform user, and skip the current diagram.
            # Do not try to include it.
            drawio_error$raise(errors, abort = FALSE)
            return(invisible(NULL))
        } else if (on.error == "continue") {
            # Raise a warning to inform user, and then continue. Let knitr
            # try to include the produced diagram. If drawio really crashed,
            # the diagram may not exists, and knitr will raise its own error!
            drawio_error$raise(errors, abort = FALSE)
        }
    }

    if (options$include) {
        knitr::engine_output(
            options,
            out = list(knitr::include_graphics(command$output))
        )
    }
}

#' Detect errors when invoking draw.io
#'
#' This function parses the *draw.io* output to detect errors.
#'
#' Drawio may encounter errors when invoked, i.e., when exporting a diagram,
#' for example the diagram source file may be incorrect.
#' However, they are not visible to the user, because:
#'
#' 1. *draw.io* is an invoked process that *knitr* does not know about.
#' 2. *draw.io* never returns a non-0 code that would indicate an error.
#'
#' Instead, errors are reported in the output (*stdout* / *stderr*).
#' These errors need to be detected automatically by **knitrdrawio**, so
#' that they can be reported to the user, and eventually stop the *knitr*
#' process if they are blocking.
#'
#' Additionally, this function is responsible for ignoring known errors that
#' are not linked to *draw.io* itself (for example, errors related to *dbus*
#' or *dri3*).
#'
#' @param output The output result from the invocation of *draw.io*, i.e.,
#' the standard output and error streams (*stdout* and *stderr*) combined.
#' It should be a vector of characters, where each element is a line.
#'
#' @return Error lines filtered from the `output` param, if they exist, or
#' `NULL` otherwise.
#'
#' @md
detect.errors <- function (output) {
    # drawio relies on Electron, and it is a known bug that Electron tries
    # to connect to dbus, which does not exist in Docker containers.
    # Several error messages related to dbus can thus be safely ignored.
    # https://github.com/electron/electron/issues/10345
    output <- grep("Failed to connect to the bus", output,
                   value = TRUE, fixed = TRUE, invert = TRUE)

    # Another known bug is related to the GPU and the DRI3 extension.
    # Normally, using `--disable-gpu` in drawio should avoid using the GPU, thus
    # not producing any error message ; for an unknwon reason, it still does.
    output <- grep("dri3 extension not supported", output,
                   value = TRUE, fixed = TRUE, invert = TRUE)

    if (length(grep("Error", output)) > 0) {
        # drawio reported an error, we return the whole message (not only lines
        # that contain "Error"), but without the previously removed lines
        # (dbus and dri3 can be ignored).
        output
    } else {
        # No error
        NULL
    }
}
