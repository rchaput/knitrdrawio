#' Get (simplified) Operating System type
#'
#' This functions returns a simple name for the current OS: "Linux", "Darwin",
#' or "Windows".
#'
get.os.type <- function () {
    # See https://www.r-bloggers.com/2015/06/identifying-the-os-from-r/
    sysinfo <- Sys.info()
    if (!is.null(sysinfo)) {
        os <- sysinfo[['sysname']]
    } else {
        os <- .Platform$OS.type
    }
    return(os)
}
