% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/WAP.R
\name{WAP}
\alias{WAP}
\title{WAP}
\usage{
WAP(
  X1 = X,
  X2 = X,
  Y1 = Y1,
  Y2 = Y2,
  psi1,
  psi2,
  num_A = 10,
  iter = 5000,
  burn_in = 3000,
  output_type = "chain",
  alpha_rho = 0.001,
  kappa_rho = 1000,
  alpha_iv = 1000,
  kappa_iv = 0.001,
  prior_initials = rep(1, 17),
  nslice = 2,
  printevery = 100
)
}
\arguments{
\item{X1}{An nxp matrix of covariates for the Weibull response. Each column represents a covariate. Each row corresponds to one of the n replicates.}

\item{X2}{An nxp matrix of covariates for the Poisson response. Each column represents a covariate. Each row corresponds to one of the n replicates.}

\item{Y1}{An n dimensional vector consisting of totals associated with Weibull observations.}

\item{Y2}{An n dimensional vector consisting of totals associated with Poisson observations.}

\item{psi1}{An nxr matrix of basis functions for the Weibull response. Each column represents a basis function. Each row corresponds to one of the n replicates.}

\item{psi2}{An nxr matrix of basis functions for the Poisson response. Each column represents a basis function. Each row corresponds to one of the n replicates.}

\item{num_A}{Hyperparameter for the adaptive rejection algorithm}

\item{iter}{The number of iterations of the collapsed Gibbs sampler}

\item{burn_in}{The size of the burn-in for the MCMC.}

\item{output_type}{Can be specified to be the entire chain 'chain', or the posterior means 'mean'.}

\item{alpha_rho}{The rate parameter of the prior for the elements of the covariance parameter.}

\item{kappa_rho}{The rate parameter of the prior for the Weibull distribution's shape parameter.}

\item{prior_initials}{The initial values of the shape parameters}

\item{nslice}{The burnin for the slice sampler}

\item{printevery}{Option to print the iteration number of the MCMC.}
}
\value{
ans A list of updated parameter values from WAP (when output_type = 'chain'). A list of posterior means from WAP (when output_type='mean').
}
\description{
This code implements a version of the collapsed Gibbs sampler from Xu et al. (2019). The model assumes that data follow Weibull and Poisson distributions with a log link to a mixed effects model. The priors and random effects are assumed to follow a multivariate log-gamma distribution.
}
\examples{


library(CM)

set.seed(123000)
n = 500
locs = seq(-2*pi,2*pi,length.out=n)

a1=-0.5
b1=3/2
a2=-2/3
b2=-2

q1 = a1+b1*sin(locs)
q2 = a2 + b2*q1

Y1 = q1+sqrt(var(a1+b1*sin(locs))/(n*5))*rnorm(n)
Y2 = q2+sqrt(var(a1 + b2*q1)/(n*5))*rnorm(n)

X1=matrix(1,n,1)
X2 = matrix(1,n,1)

r = 20
knots = seq(-2*pi,2*pi,length.out=r)
psi1 = THINSp(as.matrix(locs),as.matrix(knots))
psi2 = psi1

Z1=rweibull(n,1,exp(-Y1))
Z2=rpois(n,exp(Y2))

#plot data
plot(Z2)
plot(Z1)

# example here is for the chain output
ans=WAP(X1,X2,Z1,Z2,psi1,psi2,num_A=100,iter=2000,burn_in = 1000,nslice=50)


#estimate versus truth
q1_mcmc=X1\%*\%ans$beta1+psi1\%*\%ans$eta+psi1\%*\%ans$eta1+ans$gamma1;
q1hat = apply(q1_mcmc, 1, mean)
q1bounds = apply(q1_mcmc, 1, quantile, probs = c(0.025,0.975))

plot(locs,q1,ylim=range(c(q1bounds)))
lines(sort(locs),q1hat,col="red")
lines(sort(locs),q1bounds[1,],col="blue")
lines(sort(locs),q1bounds[2,],col="blue")

q2_mcmc=X2\%*\%ans$beta2+psi2\%*\%ans$eta+psi2\%*\%ans$eta2+ans$gamma2;
q2hat = apply(q2_mcmc, 1, mean)
q2bounds = apply(q2_mcmc, 1, quantile, probs = c(0.025,0.975))

plot(locs,q2,ylim=range(c(q2bounds)))
lines(sort(locs),q2hat,col="red")
lines(sort(locs),q2bounds[1,],col="blue")
lines(sort(locs),q2bounds[2,],col="blue")
}
