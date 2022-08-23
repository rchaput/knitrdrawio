#' Detect headless environments
#'
#' This functions detects whether the code runs in a "headless" environment,
#' i.e., with no graphical server available.
#'
#' The draw.io application requires a graphical server to work, this is a
#' known limitation. However, headless environments such as Docker containers,
#' CI/CD pipelines, remote server (through SSH), etc., do not have a display.
#'
#' It is thus important to be able to detect such environments, in order to
#' use workarounds that prevent draw.io from crashing.
#'
#' We use 2 methods:
#'
#' 1. If the \code{xrandr} tool is available, we use it to query the
#'   configuration of the current display. If `xrandr` does not find any
#'   display, we assume to be in a headless environment.
#'
#' 2. Otherwise, we resort to a simpler test: on Linux, the \code{$DISPLAY}
#'   environment variable controls the display server which should be used.
#'   If it is empty, or not set, we assume to be in a headless environment.
#'
#' @note In both methods, it is possible that the system has an available
#' display, which is simply not recognized at the time, e.g., because of an
#' incorrect configuration. This is especially the case if \code{$DISPLAY} is
#' set to \code{""}. In this case, this functions will incorrectly believe to
#' be in a headless environment. Users should make sure that their system is
#' properly configured to avoid this.
#'
#' These 2 proposed ways do not cover Windows nor Mac OS X. On such
#' systems, the headless detection will certainly fail. By default, we consider
#' we are not in a headless environment: the knitrdrawio engine will thus
#' invoke draw.io normally. Maybe, by chance, it will work. The worst possible
#' outcome is that draw.io crashes, and the document rendering will fail as
#' well.
#'
#' @md
#'
is.headless.env <- function () {
    # Solution 1: use `xrandr --query`. It returns 1 if no display is available.
    # Note that xrandr returns 0 if a virtual display has been found, e.g.,
    # when running `Xvfb :1 &` then `export DISPLAY=":1"`. This is perfect,
    # as in this case we can consider that a display exists, draw.io will work.
    xrandr <- Sys.which("xrandr")
    if (xrandr != "") {
        res <- system2(xrandr, args = "--query", stdout = FALSE, stderr = FALSE)
        return(res != 0)
    }

    # Solution 2: check whether we are on Linux, and $DISPLAY is set.
    return(get.os.type() == "Linux" && Sys.getenv("DISPLAY") == "")
}

#' Use a virtual display to run draw.io
#'
#' The draw.io application requires a display to work, which does not exist
#' in some environments ("headless"). In this case, we can use \code{xvfb} to
#' emulate a virtual display in place of the physical display.
#'
#' This method checks that \code{xvfb-run} can be found, and wraps the
#' command-line call to draw.io as a call to \code{xvfb-run}, with additional
#' parameters that help draw.io work in headless environments.
#'
#' The returned value has the same structure as the \code{parse.options} method:
#' \code{exe} is the path to the executable (in this case, \code{xvfb-run}
#' instead of draw.io), \code{args} are the arguments, and \code{output} is
#' left unchanged (path to the output file).
#'
#' @param command The list that represents the command that should have been
#' executed, in a non-headless environment. This list should be the result
#' of a call to \code{\link{parse.options}}. It must have the following
#' values: \code{exe}, \code{args}, and \code{output}.
#'
#' @return exe The path to the xvfb-run executable binary.
#' @return args The list of command line arguments to be passed to xvfb,
#' including the path to the draw.io executable, the draw.io arguments,
#' and electron arguments for headless mode.
#' @return output The path to the image that will result from the execution
#' of `\code{exe} \code{args}` (including the cache directory, if it was
#' specified). This is exactly the same as the value in the \code{command}
#' argument.
#'
wrap.xvfb <- function (command) {
    # Check if xvfb-run exists on the system
    new_exe <- Sys.which("xvfb-run")
    if (new_exe == "") {
        xvfb_binary_not_found$raise(call = rlang::caller_env())
    }

    # electron arguments must go *after* the last draw.io argument ; otherwise,
    # draw.io mistakes them for input files (which will not work).
    electron_args <- c("--disable-gpu", "--no-sandbox")
    new_args <- c("--auto-servernum", command$exe, command$args,
                  electron_args)
    return(list(exe = new_exe, args = new_args, output = command$output))
}
