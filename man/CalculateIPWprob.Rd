% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utilities.R
\name{CalculateIPWprob}
\alias{CalculateIPWprob}
\title{Calculate the Remaining Probabilities in Inverse Probability Weights}
\usage{
CalculateIPWprob(m, Y, order, alpha, sub.num = 0)
}
\arguments{
\item{m}{an integer vector of number of measurements for each subject.}

\item{Y}{a vector of responses for all subjects.}

\item{order}{the order for MAR remaining model.}

\item{alpha}{parameters in MAR remaining model.}

\item{sub.num}{subject number (0 = all subjects).}
}
\description{
Calculate a vector of remaining probabilities in inverse
  probability weights for one specific or all subjects
}
