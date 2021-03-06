# Name: Christian Peters

library(MASS)

set.seed(1234)

# No. 18)
# =======

# define model parameters
beta <- c(100, 5, 10, -15)
X <- matrix(c(1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1), nrow=6)
X_inv <- ginv(X)
B <- t(c(0, 1, 1, 1))
XB <- X %*% (diag(4) - ginv(B) %*% B)
XB_inv <- ginv(XB)
stdev <- 10
n <- 10000

# simulate without side condition
results_1 <- replicate(n, t(c(1, 1, 0, 0)) %*% X_inv %*% (X %*% beta + rnorm(6, sd=stdev)))
# bias: mean(results_1) - 105 = 0.0329613
results_2 <- replicate(n, t(c(1, 2, -1, 0)) %*% X_inv %*% (X %*% beta + rnorm(6, sd=stdev)))
# bias: mean(results_2) - 100 = -0.03319558
results_3 <- replicate(n, t(c(0, 0, 1, -1)) %*% X_inv %*% (X %*% beta + rnorm(6, sd=stdev)))
# bias: mean(results_3) - 25 = 0.03582676
results_4 <- replicate(n, t(c(0, 1, 1, 0)) %*% X_inv %*% (X %*% beta + rnorm(6, sd=stdev)))
# bias: mean(results_4) - 15 = 49.98625
results_5 <- replicate(n, t(c(1, 0, 0, 0)) %*% X_inv %*% (X %*% beta + rnorm(6, sd=stdev)))
# bias: mean(results_5) - 100 = -25.02991

# plot the results
boxplot(results_1, results_2, results_3, results_4, results_5, names = c('i', 'ii', 'iii', 'iv', 'v'), main='LS Estimates Unrestricted')

# simulate with side condition
results_1_r <- replicate(n, t(c(1, 1, 0, 0)) %*% XB_inv %*% (X %*% beta + rnorm(6, sd=stdev)))
# bias: mean(results_1_r) - 105 = -0.05964415
results_2_r <- replicate(n, t(c(1, 2, -1, 0)) %*% XB_inv %*% (X %*% beta + rnorm(6, sd=stdev)))
# bias: mean(results_2_r) - 100 = -0.004516509
results_3_r <- replicate(n, t(c(0, 0, 1, -1)) %*% XB_inv %*% (X %*% beta + rnorm(6, sd=stdev)))
# bias: mean(results_3_r) - 25 = -0.01391626
results_4_r <- replicate(n, t(c(0, 1, 1, 0)) %*% XB_inv %*% (X %*% beta + rnorm(6, sd=stdev)))
# bias: mean(results_4_r) - 15 = 0.05490545
results_5_r <- replicate(n, t(c(1, 0, 0, 0)) %*% XB_inv %*% (X %*% beta + rnorm(6, sd=stdev)))
# bias: mean(results_5_r) - 100 = 0.002658646

# plot the results
boxplot(results_1_r, results_2_r, results_3_r, results_4_r, results_5_r, names = c('i', 'ii', 'iii', 'iv', 'v'), main='LS Estimates Restricted')

# We can see that in the unrestricted case the bias is close to zero for all linear unbiased estimable functions (i-iii).
# Looking at functions iv and v, we can see that the bias is clearly unequal to zero.
# In the restricted case, the bias is zero for all estimators.

# No. 19)
# =======

data <- read.csv2('cars.csv')

# a)

# create design matrix and response vector
X <- cbind(1, data$Hubraum, data$Leistung, data$Gewicht, data$Verbrauch)
y <- data$Preis

# get the least squares estimate (gauss-markov-estimate)
beta <- solve(t(X) %*% X, t(X) %*% y)
# -13614.6216356691, 526.935980973853, 145.011255933093, 19141.205906062, 739.892449453102

# Interpretation:
# Intercept: no useful way of interpretation
# beta_1: 526.94 euros per liter of engine displacement
# beta_2: 145.01 euros per horsepower
# beta_3: 19141.21 euros per ton of weight
# beta_4: 739.89 euros per liter of fuel consumption

# b)

# get a scaled version of the covariance matrix
cov_scaled <- solve(t(X) %*% X)

# scale it to get the correlation matrix
cor_estimate <- diag(1/sqrt(diag(cov_scaled))) %*% cov_scaled %*% diag(1/sqrt(diag(cov_scaled)))
print(cor_estimate)

# We can see that the correlation between b_1 (engine displacement) and b_2 (horsepower) is -0.77685540.
# This means that the estimates of these two coefficients will vary together in
# different directions. This is not a desirable trait because this behavior makes it difficult
# to distinguish between the effects of engine displacement and horsepower on the price of a car.
# One reason for this is most likely that there is a general correlation between
# horsepower and engine displacement. (Cars with bigger engines tend to have more horsepower).

# c)

# estimate the new beta vector
beta_ridge <- solve(t(X) %*% X + 0.1 * diag(5), t(X) %*% y)
# -12360.8612982283, 248.469501354341, 160.381659732185, 13986.5685515175, 1204.63367627605

# get a scaled version of the covariance matrix (cov_ridge = sigma^2 * cov_scaled_ridge)
A <- solve(t(X) %*% X + 0.1 * diag(5)) %*% t(X)
cov_scaled_ridge <- A %*% t(A)
# var(b_1_ridge) = sigma^2 * 0.0003609379 (cov_scaled_ridge[3, 3])
# var(b_1) = sigma^2 * 0.0004309017 (cov_scaled[3, 3])

# As we can see, the variance as well as the absolute value of beta_1 is reduced when applying the new technique.
# These results are still consistent with the Gauss-Markov-Theorem because the
# new estimate of the beta coefficient vector is not unbiased.