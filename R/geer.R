#' @useDynLib gee4
#' @importFrom Rcpp evalCpp
NULL

#' @import stats
NULL

#' @import graphics
NULL

#' Cattle Data
#'
#' Kenward (1987) reported an experiment in which cattle were assigned randomly
#' to two treatment groups A and B, and their body weights were recorded in
#' kilogram. Thirty animals received treatment A and another 30 received
#' treatment B. The animals were weighted 11 times over a 133-day period; the
#' first 10 measurements for each animal were made at two-week intervals and the
#' last measurement was made one week later. Since no observation was missing,
#' it is considered to be a balanced longitudinal dataset.
#'
#' \itemize{
#'   \item id: subject id
#'   \item day: measurement time
#'   \item group: Treatment A or Treatment B
#'   \item weight: cattle weight
#' }
#'
#' @docType data
#' @keywords datasets
#' @name cattle
#' @usage data(cattle)
#' @format A data frame with 660 rows and 4 variables
NULL


#' Aids Data
#'
#' The aids dataset comprises a total of 2376 CD4+ cell counts for 369 HIV
#' infected men with a follow up period of approximately eight and half year.
#' The number of measurements for each individual varies from 1 to 12 and the
#' times are not equally spaced. The CD4+ cell data are highly unbalanced.
#'
#' \itemize{
#'   \item id: subject id
#'   \item time: measurement time
#'   \item cd4: CD4+ cell count
#' }
#'
#' @docType data
#' @keywords datasets
#' @name aids
#' @usage data(aids)
#' @format A data frame with 2376 rows and 8 variables
NULL


#' @title Fit Joint Mean-Covariance Models
#'
#' @description Fit a joint mean-covariance model to longitudinal data within
#' the within the framework of generalised estimating equations (GEE), via the
#' Newton-Raphson method.
#'
#' @param formula a two-sided linear formula object describing the covariates
#' for both the mean and covariance matrix part of the model, with the response,
#' the corresponding subject id and measurement time on the left of a operator~,
#' divided by vertical bars ("|").
#' @param data a data frame containing the variables named in formula.
#' @param triple an integer vector of length three containing the degrees of the
#' three polynomial functions for the mean structure, the log innovation
#' -variances and the autoregressive or moving average coefficients when 'mcd'
#' or 'acd' is specified for cov.method. It refers to the degree for the mean
#' structure, variances and angles when 'hpc' is specified for cov.method.
#' @param corr.struct covariance structure modelling method,
#' choose 'mcd' (Pourahmadi 1999), 'acd' (Chen and Dunson 2013, not available yet)
#' or 'hpc' (Zhang et al. 2015, not available yet).
#' @param rho a parameter used in the sandwich 'working' covariance structure.
#' @param control a list (of correct class, resulting from geerControl())
#' containing control parameters, see the *geerControl documentation for
#' details.
#' @param start starting values for the parameters in the model.
#'
#' @examples
#' cattleA <- cattle[cattle$group=='A', ]
#' fit.mcd <- geer(weight | id | I(ceiling(day/14 + 1)) ~ 1 | 1,
#' data=cattleA, triple = c(8, 2, 2), rho = 0.5, corr.struct = 'cs')
#' @export
geer <- function(formula, data = NULL, triple = c(3, 3, 3), rho = 0.5,
                 corr.struct = c('id', 'cs', 'ar1'),
                 control = geerControl(), start = NULL)
{
  mc <- mcout <- match.call()

  if (missing(corr.struct))
    stop("corr.struct must be specified")

  missCtrl <- missing(control)
  if (!missCtrl && !inherits(control, "geerControl"))
  {
    if(!is.list(control))
      stop("'control' is not a list; use geerControl()")

    warning("please use geerControl() instead", immediate. = TRUE)
    control <- do.call(geerControl, control)
  }

  mc[[1]] <- quote(gee4::ldFormula)
  args <- eval(mc, parent.frame(1L))

  opt <- do.call(optimizeGeer,
    c(args, corr.struct, rho, list(control=control, start=start)))

  mkGeerMod(opt=opt, args=args, triple=triple, rho = rho, corr.struct=corr.struct, mc=mcout)
}

#' @title Modular Functions for Joint Mean Covariance Model Fits
#'
#' @description Modular Functions for joint mean covariance model fits
#'
#' @param formula a two-sided linear formula object describing the covariates
#' for both the mean and covariance matrix part of the model, with the response,
#' the corresponding subject id and measurement time on the left of a operator~,
#' divided by vertical bars ("|").
#' @param data a data frame containing the variables named in formula.
#' @param triple an integer vector of length three containing the degrees of the
#' three polynomial functions for the mean structure, the log innovation
#' -variances and the autoregressive or moving average coefficients when 'mcd'
#' or 'acd' is specified for cov.method. It refers to the degree for the mean
#' structure, variances and angles when 'hpc' is specified for cov.method.
#' @param rho a parameter used in the sandwich 'working' covariance structure
#' @param corr.struct covariance structure modelling method,
#' choose 'mcd' (Pourahmadi 1999), 'acd' (Chen and Dunson 2013) or 'hpc'
#' (Zhang et al. 2015).
#' @param control a list (of correct class, resulting from geerControl())
#' containing control parameters, see the *geerControl documentation for
#' details.
#' @param start starting values for the parameters in the model.
#' @param m an integer vector of number of measurements for each subject.
#' @param Y a vector of responses for all subjects.
#' @param X model matrix for mean structure model.
#' @param Z model matrix for the diagonal matrix.
#' @param W model matrix for the lower triangular matrix.
#' @param time a vector of time from the data.
#' @param opt optimized results returned by optimizeGeer.
#' @param args arguments returned by ldFormula.
#' @param mc matched call from the calling function.
#'
#' @name modular
NULL
#> NULL

#' @rdname modular
#' @export
ldFormula <- function(formula, data = NULL, triple = c(3,3,3),rho=0.5,
                      corr.struct = c('id','cs','ar1'),
                      control = geerControl(), start = NULL)
{
  mf <- mc <- match.call()
  m <- match(c("formula", "data"), names(mf), 0L)
  mf <- mf[c(1, m)]

  f <- Formula::Formula(formula)
  mf[[1]] <- as.name("model.frame")
  mf$formula <- f
  mf <- eval(mf, parent.frame())

  Y    <- Formula::model.part(f, data = mf, lhs = 1)
  id   <- Formula::model.part(f, data = mf, lhs = 2)
  time <- Formula::model.part(f, data = mf, lhs = 3)

  X <- model.matrix(f, data = mf,rhs = 1)
  Z <- model.matrix(f, data = mf,rhs = 2)

  index <- order(id, time)

  Y    <- Y[index, ]
  id   <- id[index, ]
  time <- time[index, ]

  m <- table(id)
  attr(m, "dimnames") <- NULL

  X <- X[index, ]
  Z <- Z[index, ]
  for (i in 1:triple[1]) X = cbind(X, time^i)
  for (i in 1:triple[2]) Z = cbind(Z, time^i)

  W <- NULL
  for (i in 1:length(m))
  {
    if (i == 1) {
      ti <- time[1:m[1]]
    } else {
      first_index <- 1+sum(m[1:(i-1)])
      last_index <- sum(m[1:i])
      ti <- time[first_index:last_index]
    }

    if(m[i] != 1) {
      for (j in 2:m[i])
      {
        for (k in 1:(j - 1))
        {
          wijk = (ti[j]-ti[k])^(0:triple[3])
          W = rbind(W,wijk)
        }
      }
    }
  }

  attr(X, "dimnames") <- NULL
  attr(Z, "dimnames") <- NULL
  attr(W, "dimnames") <- NULL

  p <- triple[1]
  d <- triple[2]
  q <- triple[3]

  list(m = m, Y = Y, X = X, Z = Z, W = W, time = time)
}

#' @rdname modular
#' @export
optimizeGeer <- function(m, Y, X, Z, W, time, corr.struct, rho, control, start)
{
  missStart <- is.null(start)

  lbta <- ncol(X)
  llmd <- ncol(Z)
  lgma <- ncol(W)

  if(!missStart && (lbta+llmd+lgma) != length(start))
    stop("Incorrect start input")

  if (missStart) {
    lm.obj <- lm(Y ~ X - 1)
    bta0 <- coef(lm.obj)

    resid(lm.obj) -> res
    lmd0 <- coef(lm(log(res^2) ~ Z - 1))
    gma0 <- rep(0, lgma)

    start <- c(bta0, lmd0, gma0)
  }

  if (corr.struct == 'id') {
    est <- geerfit_id(m, Y, X, Z, W, rho, start, control$trace, control$profile, control$errorMsg)
  }

  if (corr.struct == 'cs') {
    est <- geerfit_cs(m, Y, X, Z, W, rho, start, control$trace, control$profile, control$errorMsg)
  }

  if (corr.struct == 'ar1') {
    est <- geerfit_ar1(m, Y, X, Z, W, rho, start, control$trace, control$profile, control$errorMsg)
  }

  if (!(control$ignore.const.term)) {
    const.term = - sum(m) * 0.5 * log(2 * pi)
    est$quasilik = est$quasilik + const.term
    est$QIC = est$QIC - 2 / length(m) * const.term
  }

  est
}

#' @rdname modular
#' @export
mkGeerMod <- function(opt, args, triple, rho, corr.struct, mc)
{
  if(missing(mc))
    mc <- match.call()

  isID <- (corr.struct == 'id')
  isCS <- (corr.struct == "cs")
  isAR1 <- (corr.struct == "ar1")

  dims  <- c(nsub     = length(args$m),
    max.nobs = max(args$m),
    p   = triple[1],
    d   = triple[2],
    q   = triple[3],
    ID = isID,
    CS = isCS,
    AR1 = isAR1)
  new("geerMod", call=mc, opt=opt, args=args,
    triple=triple, rho=rho, devcomp=list(dims=dims) )
}

###----- Printing etc ----------------------------
methodTitle <- function(object, dims = object@devcomp$dims)
{
  ID <- dims[["ID"]]
  CS <- dims[["CS"]]
  AR1 <- dims[["AR1"]]
  kind <- switch(ID * 1L + CS * 2L + AR1 * 3L, "ID", "CS", "AR1")
  paste("Joint mean-covariance model based on GEE ( structure of Ri:", kind, ")")
}

cat.f <- function(...) cat(..., fill = TRUE)

.prt.methTit <- function(mtit, class) {
  cat(sprintf("%s ['%s']\n", mtit, class))
}

.prt.call <- function(call, long = TRUE) {
  if (!is.null(cc <- call$formula))
    cat.f("Formula:", deparse(cc))
  if (!is.null(cc <- call$triple))
    cat.f(" triple:", deparse(cc))
  if (!is.null(cc <- call$rho))
    cat.f("    rho:", deparse(cc))
  if (!is.null(cc <- call$data))
    cat.f("   Data:", deparse(cc))
}

.prt.quasilik <- function(n2ll, digits=4)
{
  t.4 <- round(n2ll, digits)
  cat.f("quasiLik:", t.4)
}

.prt.qic <- function(qic, digits=4)
{
  t.4 <- round(qic, digits)
  cat.f("   QIC_u:", t.4)
}

print.geerMod <- function(x, digits=4, ...)
{
  dims <- x@devcomp$dims
  .prt.methTit(methodTitle(x, dims = dims), class(x))
  .prt.call(x@call); cat("\n")
  .prt.quasilik(x@opt$quasilik)
  .prt.qic(x@opt$QIC); cat("\n")

  cat("Mean Parameters:\n")
  print.default(format(drop(x@opt$beta), digits = digits),
    print.gap = 2L, quote = FALSE)

    cat("Innovation Variance Parameters:\n")
  print.default(format(drop(x@opt$lambda), digits = digits),
    print.gap = 2L, quote = FALSE)

    cat("Autoregressive Parameters:\n")
  print.default(format(drop(x@opt$gamma), digits = digits),
    print.gap = 2L, quote = FALSE)

  invisible(x)
}

#' Print information for geerMod-class
#'
#' @param object a fitted joint mean covariance model of class "geerMod", i.e.,
#' typically the result of geer().
#'
#' @exportMethod show
setMethod("show", "geerMod", function(object) print.geerMod(object))

summary.geerMod <- function(x, digits=4, ...)
{
  dims <- x@devcomp$dims
  .prt.methTit(methodTitle(x, dims = dims), class(x))
  .prt.call(x@call); cat("\n")
  .prt.quasilik(x@opt$quasilik)
  .prt.qic(x@opt$QIC); cat("\n")

  cat("Mean Parameters:\n")
  print.default(format(drop(x@opt$beta), digits = digits),
    print.gap = 2L, quote = FALSE)

  if(dims["MCD"] == 1 || dims["ACD"] == 1)
    cat("Innovation Variance Parameters:\n")
  else if(dims["HPC"] == 1)
    cat("Variance Parameters:\n")
  print.default(format(drop(x@opt$lambda), digits = digits),
    print.gap = 2L, quote = FALSE)

  if(dims["MCD"] == 1)
    cat("Autoregressive Parameters:\n")
  else if(dims["ACD"] == 1)
    cat("Moving Average Parameters:\n")
  else if(dims["HPC"] == 1)
    cat("Angle Parameters:\n")
  print.default(format(drop(x@opt$gamma), digits = digits),
    print.gap = 2L, quote = FALSE)

  invisible(x)
}

# bdbind <- function(A, B)
# {
#   stopifnot(isSymmetric(A))
#   stopifnot(isSymmetric(B))
#   dimA <- dim(A)[1]
#   dimB <- dim(B)[1]
#
#   res <- matrix(0, dimA+dimB, dimA+dimB)
#   res[1:dimA, 1:dimA] = A
#   res[(dimA+1):(dimA+dimB), (dimA+1):(dimA+dimB)] = B
#   res
# }
#
# vcov.merMod <- function(object)
# {
#   args <- object@args
#   dims <- object@devcomp$dims
#   par  <- object@opt$par
#
#   m <- args[["m"]]
#   Y <- args[["Y"]]
#   X <- args[["X"]]
#   Z <- args[["Z"]]
#   W <- args[["W"]]
#
#   if(dims[["MCD"]] == 1) {
#     mcdobj <-  new("MCD", m, Y, X, Z, W)
#     res <- solve(mcdobj$meancovi(par, 1)$Sigmai)
#     for(i in 2:length(m)) {
#       res <- bdbind(res, solve(mcdobj$meancovi(par, i)$Sigmai))
#     }
#   }
#   res <- solve(t(X) %*% res %*% X)
# }
