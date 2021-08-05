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
    result <- parse.options(options)
    cmd <- result$cmd
    output <- result$output

    # Execute the command
    system(cmd)

    if (options$include) {
        knitr::engine_output(
            options,
            out = list(knitr::include_graphics(output))
        )
    }
}
