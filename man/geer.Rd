% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/geer.R
\name{geer}
\alias{geer}
\title{Fit GEE-MCD and WGEE-MCD models}
\usage{
geer(formula, data = NULL, triple = c(3, 3, 3), method = c("gee-mcd",
  "wgee-mcd"), corr.struct = c("id", "cs", "ar1"), rho = 0.5,
  ipw.order = 1, weights.vec = NULL, control = geerControl(),
  start = NULL)
}
\arguments{
\item{formula}{a two-sided linear formula object describing the covariates
for both the mean and covariance matrix part of the model, with the
response, the corresponding subject id and measurement time on the left of
a operator~, divided by vertical bars ("|").}

\item{data}{a data frame containing the variables named in formula.}

\item{triple}{an integer vector of length three containing the degrees of the
three polynomial functions for the mean structure, the log innovation
-variances and the autoregressive coefficients.}

\item{method}{choose 'gee-mcd' (Ye and Pan, 2006) or 'wgee-mcd' (Pan et al.
2012).}

\item{corr.struct}{choose 'id' (independent), 'cs' (compound symmetry) or
'ar1' (AR(1)).}

\item{rho}{a parameter used in the 'working' covariance structure.}

\item{ipw.order}{the order for MAR remaining model.}

\item{weights.vec}{a user specified vector for the weights H in WGEE-MCD.}

\item{control}{a list (of correct class, resulting from geerControl())
containing control parameters, see the *geerControl documentation for
details.}

\item{start}{starting values for the parameters in the model.}
}
\description{
Fit a modified Cholesky decomposition (MCD) based joint mean
  covariance model to longitudinal data within the framework of (weighted)
  generalised estimating equations (GEE/WGEE), via the Newton-Raphson method.
}
\examples{
fitgee.normal <- geer(cd4 | id | time ~ 1 | 1, data = aids, triple
  = c(6,3,3), method = 'gee-mcd', corr.struct = 'id', control =
  geerControl(trace=TRUE))
}
