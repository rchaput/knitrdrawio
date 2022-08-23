#' Knitrdrawio conditions
#'
#' Helper functions to raise conditions (errors, warnings, ...).
#'
#' These conditions have a specific class (so they can be recognized easily),
#' and include condition-specific details.
#' For example, if the `format` option is incorrect, the condition will
#' provide a `format` field.
#'
#' For each kind of condition, we provide a structure containing both the
#' `classname`, and a `raise` function. It is thus possible to retrieve
#' the classnames programmatically to check whether a given condition
#' belongs to a given kind.
#'

unrecognized_os <- list(
  classname = "knitrdrawio_unrecognized_os",
  raise = function (os, call = rlang::caller_env()) {
    cli::cli_abort(
      class = unrecognized_os$classname,
      message = c(
        "Can't find the path to {.emph drawio}.",
        "x" = "Your OS {.val {os}} was not recognized.",
        "i" = "Please set the path to {.emph drawio} by using the {.field engine.path} chunk option.",
        "i" = "See the {.strong ?knitrdrawio::drawio.default.path} documentation for details."
      ),
      os = os,
      call = call
    )
  }
)

drawio_binary_not_found <- list(
  classname = "knitrdrawio_drawio_binary_not_found",
  raise = function (os, call = rlang::caller_env()) {
    cli::cli_abort(
      class = drawio_binary_not_found$classname,
      message = c(
        "Can't find the path to {.emph drawio}.",
        "i" = "Have you installed {.emph drawio} on your OS ({.val os})?",
        "i" = "Please set the path to {.emph drawio} by using the {.field engine.path} chunk option.",
        "i" = "See the {.strong ?knitrdrawio::drawio.default.path} documentation for details."
      ),
      os = os,
      call = call
    )
  }
)

drawio_binary_not_exists <- list(
  classname = "knitdrawio_drawio_binary_not_exists",
  raise = function (path, call = rlang::caller_env()) {
    cli::cli_warn(
      class = drawio_binary_not_exists$classname,
      message = c(
        "The {.emph drawio} binary must exists.",
        "i" = "The default path {.path {path}} was used.",
        "i" = "Please set the path to {.emph drawio} by using the {.field engine.path} chunk option.",
        "i" = "See the {.strong ?knitrdrawio::drawio.default.path} documentation for details."
      ),
      path = path,
      call = call
    )
  }
)

drawio_binary_not_executable <- list(
  classname = "knitrdrawio_drawio_binary_not_executable",
  raise = function (path, call = rlang::caller_env()) {
    cli::cli_warn(
      class = drawio_binary_not_executable$classname,
      message = c(
        "The {.emph drawio} binary must be executable.",
        "i" = "{.emph drawio} was found at {.path {path}}.",
        "i" = "Please make sure the binary is executable.",
        "i" = "Or set the path to {.emph drawio} by using the {.field engine.path} chunk option.",
        "i" = "See the {.strong ?knitrdrawio::drawio.default.path} documentation for details."
      ),
      path = path,
      call = call
    )
  }
)

xvfb_binary_not_found <- list(
  classname = "knitrdrawio_xvfb_binary_not_found",
  raise = function (call = rlang::caller_env()) {
    cli::cli_abort(
      class = xvfb_binary_not_found$classname,
      message = c(
        "{.emph xvfb-run} must be installed in a headless environment.",
        "i" = "knitrdrawio detected a headless environment and requires {.emph xvfb-run} when no monitor is connected.",
        "i" = "If you believe this should not be a headless environment, make sure the {.envvar DISPLAY} environment variable is set."
      ),
      call = call
    )
  }
)

transparent_incorrect_format <- list(
  classname = "knitrdrawio_transparent_incorrect_format",
  raise = function (format, call = rlang::caller_env()) {
    cli::cli_warn(
      class = transparent_incorrect_format$classname,
      message = c(
        "{.field transparent} option is only supported when {.field format} is {.val png}.",
        "x" = "{.field format} was {.val {format}}.",
        "i" = "Continuing: the result will not be transparent."
      ),
      format = format,
      call = call
    )
  }
)

pagerange_incorrect_format <- list(
  classname = "knitrdrawio_pagerange_incorrect_format",
  raise = function (format, call = rlang::caller_env()) {
    cli::cli_warn(
      class = pagerange_incorrect_format$classname,
      message = c(
        "{.field page.range} option is only supported when {.field format} is {.val pdf}.",
        "x" = "{.field format} was {.val {format}}.",
        "i" = "Continuing: the result will not respect desired range."
      ),
      format = format,
      call = call
    )
  }
)

source_unspecified <- list(
  classname = "knitrdrawio_source_unspecified",
  raise = function (call = rlang::caller_env()) {
    cli::cli_abort(
      class = source_unspecified$classname,
      message = c(
        "Path to source file {.field src} must be specified in the chunk options.",
        "i" = "Please set the chunk option {.field src} to a valid drawio diagram."
      ),
      call = call
    )
  }
)

source_not_exists <- list(
  classname = "knitrdrawio_source_not_exists",
  raise = function (src, call = rlang::caller_env()) {
    cli::cli_abort(
      class = source_not_exists$classname,
      message = c(
        "Source file must exist.",
        "x" = "File {.path {src}} does not exist.",
        "i" = "Please set the chunk option {.field src} to a valid drawio diagram.",
        "i" = "Have you correctly set the current dir? (was {.path {getwd()}})"
      ),
      src = src,
      call = call
    )
  }
)
