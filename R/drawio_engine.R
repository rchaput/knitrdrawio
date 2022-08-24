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
    if (length(grep("Error", res)) > 0) {
        # draw.io reported an error in the stderr/stdout. We decide whether to
        # stop, skip, or continue. Default is to `stop`.
        on.error <- match.arg(options$on.error, c("stop", "skip", "continue"))
        if (on.error == "stop") {
            # Raise an error now and stop execution.
            # Knitr would probably raise one anyway, stopping now is more
            # informative for the user.
            drawio_error$raise(res, abort = TRUE)
        } else if (on.error == "skip") {
            # Raise a warning to inform user, and skip the current diagram.
            # Do not try to include it.
            drawio_error$raise(res, abort = FALSE)
            return(invisible(NULL))
        } else if (on.error == "continue") {
            # Raise a warning to inform user, and then continue. Let knitr
            # try to include the produced diagram. If drawio really crashed,
            # the diagram may not exists, and knitr will raise its own error!
            drawio_error$raise(res, abort = FALSE)
        }
    }

    if (options$include) {
        knitr::engine_output(
            options,
            out = list(knitr::include_graphics(command$output))
        )
    }
}
