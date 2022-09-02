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

unrecognized_format <- list(
  classname = "knitrdrawio_unrecognized_format",
  raise = function(format, allowed_formats, call = rlang::caller_env()) {
    cli::cli_warn(
      class = unrecognized_format$classname,
      message = c(
        "{.field format} must be one of {.val {allowed_formats}}.",
        "x" = "{.field format} was {.val {format}}.",
        "i" = "Continuing: drawio will produce a PDF."
      ),
      format = format,
      allowed_formats = allowed_formats,
      call = call
    )
  }
)

incorrect_param_type <- list(
  classname = "knitrdrawio_incorrect_param_type",
  raise = function (param_name, expected_type, actual_value,
                    call = rlang::caller_env()) {
    actual_type <- class(actual_value)
    cli::cli_warn(
      class = incorrect_param_type$classname,
      message = c(
        "{.field {param_name}} must be coercible to a {.cls {expected_type}}.",
        "x" = "{.val {actual_value}} is a {.cls {actual_type}}."
      ),
      param_name = param_name,
      expected_type = expected_type,
      actual_value = actual_value,
      actual_type = actual_type,
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

pagerange_incorrect_value <- list(
  classname = "knitdrawio_pagerange_incorrect_value",
  raise = function (value, call = rlang::caller_env()) {
    cli::cli_warn(
      class = pagerange_incorrect_value$classname,
      message = c(
        "{.field page.range} must be in the form {.val from..to}.",
        "x" = "{.field page.range} was {.val {value}}."
      ),
      value = value,
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

drawio_error <- list(
  classname = "knitrdrawio_drawio_error",
  raise = function (error, abort = FALSE, call = rlang::caller_env()) {
    message <- c(
      "{.emph drawio} reported an error.",
      "x" = error,
    )
    if (abort) {
      cli::cli_abort(
        class = drawio_error$classname,
        message = message,
        error = error,
        call = call
      )
    } else {
      cli::cli_warn(
        class = drawio_error$classname,
        message = message,
        error = error,
        call = call
      )
    }
  }
)
