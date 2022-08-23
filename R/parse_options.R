#' Parse Options
#'
#' This function is used to parse the given chunk options and build the
#' \code{drawio} command that will be executed to export the diagram as an
#' image.
#'
#' This function is executed by the drawio engine and should normally not
#' be used directly by the user.
#'
#' List of accepted options: (please see drawio's help for more details)
#' \describe{
#'   \item{\code{src}}{Path to the source diagram. Mandatory
#'   argument, must not be null nor empty.}
#'
#'   \item{\code{format}}{Format of the output image. Either "\code{pdf}",
#'   "\code{png}", "\code{jpg}", "\code{svg}", "\code{vsdx}", or "\code{xml}".
#'   If unspecified, a default value is set, depending on the current document
#'   output: "\code{pdf}" is used for LaTeX, "\code{svg}" for HTML, and
#'   "\code{png}" for other formats.}
#'
#'   \item{engine.path}{Path to the \code{draw.io} executable. If unspecified,
#'   the default value depends on the OS (please see
#'   \code{\link{drawio.default.path}} for details).}
#'
#'   \item{engine.opts}{Optional arguments sent as-is to \code{drawio}. Please
#'   see the \code{drawio} documentation for a list of possible arguments.}
#'
#'   \item{crop}{Whether to crop the result image or not. (Default: yes)}
#'
#'   \item{transparent}{Whether to set a transparent background or a blank
#'   background. Can only be used if `\code{format}` is "\code{pdf}".}
#'
#'   \item{border}{Width of the border surrounding the diagram. (Default: 0)}
#'
#'   \item{page.index}{Which page to export from the source diagram, if
#'   multiple pages are available.}
#'
#'   \item{page.range}{Similar to `\code{page.index}`, but allowing for
#'   multiple pages. Can only be used if `\code{format}` is "\code{pdf}".}
#'
#'   \item{fig.path}{Path to the figure directory. By default, resulting
#'   images are placed in the current working directory.}
#' }
#'
#' @param options The list of chunk options. Please see in the details for a
#' list of accepted options.
#'
#' @return exe The path to the draw.io executable binary.
#' @return args The list of command line arguments to be passed to drawio.
#' @return output The path to the image that will result from the execution
#' of `\code{exe} \code{args}` (including the cache directory, if it was
#' specified).
#'
#' @export
#'
parse.options <- function(options) {
    ### Image format
    # By default, if none is specified, the format is set based on the
    # document output format.
    # For PDFs (i.e., LaTeX output), PDF images have a better quality and can
    # be easily re-dimensioned (vectorized image).
    # For HTML, SVG images are better integrated and are also vectorized.
    # For other formats, PNG should be versatile.
    if (is.null(options$format)) {
        options$format <- if (knitr::is_latex_output()) {
            "pdf"
        } else if (knitr::is_html_output()) {
            "svg"
        } else {
            "png"
        }
    }

    ### Path to the draw.io executable
    drawio.path <- NULL
    if (!is.null(options$engine.path)) {
        if (is.list(options$engine.path)) {
            # `engine.path` is a list of engines -> paths
            drawio.path <- options$engine.path["drawio"]
        } else {
            # `engine.path` should be a path (character)
            drawio.path <- options$engine.path
        }
    }
    if (is.null(drawio.path)) {
        drawio.path <- drawio.default.path()
    }

    ### Prepare the command (list of arguments)
    args <- "--export"

    ### Crop the output? (by default, yes)
    if (isTRUE(options$crop) || is.null(options$crop)) {
        args <- c(args, "--crop")
    }

    ### Use a transparent background?
    if (isTRUE(options$transparent)) {
        if (options$format != "png") {
            transparent_incorrect_format$raise(options$format, call = rlang::caller_env())
            # Drawio should not complain, so we still add the option,
            # just in case the user really knows what (s)he's doing.
            # or doesn't care about warnings.
        }
        args <- c(args, "--transparent")
    }

    ### Border width
    if (!is.null(options$border)) {
        args <- c(args, "--border", options$border)
    }

    ### Page index (= which "page" in the diagram to export)
    if (!is.null(options$page.index)) {
        args <- c(args, "--page-index", options$page.index)
    }

    ### Page range (= multiple "page" indices)
    if (!is.null(options$page.range)) {
        if (options$format != "pdf") {
            pagerange_incorrect_format$raise(options$format, call = rlang::caller_env())
        }
        args <- c(args, "--page-range", options$page.range)
    }

    ### Additional options
    if (!is.null(options$engine.opts)) {
        if (is.list(options$engine.opts)) {
            # The `engine.opts` is a list of engines -> options
            args <- c(args, options$engine.opts["drawio"])
        } else {
            # The `engine.opts` is simply options
            args <- c(args, options$engine.opts)
        }
    }

    ### Path to the output file
    # If a figure directory is specified, we use it ; otherwise, we simply
    # use the current directory.
    # The filename consists of the chunk's label (unique identifier) + format
    filename <- paste0(options$label, ".", options$format)
    fig.dir <- options$fig.path
    if (!is.null(fig.dir)) {
        # If the path ends with a trailing `/`, delete it!
        # Otherwise, the `file.path` will output something like `path/to//file`
        # which does not work
        fig.dir <- sub("/$", "", fig.dir)
        # Create the directory/directories, in case they do not exist already
        if (!dir.exists(fig.dir)) {
            dir.create(fig.dir, recursive=TRUE)
        }
        # Finally, append the filename to the prefix path
        output <- file.path(fig.dir, filename)
    } else {
        output <- filename
    }
    args <- c(args, "--output", output)

    ### Source file
    if (is.null(options$src)) {
        source_unspecified$raise()
    } else if (!file.exists(options$src)) {
        source_not_exists$raise(options$src, call = rlang::caller_env())
    }
    args <- c(args, options$src)

    return(list(exe = drawio.path, args = args, output = output))
}
