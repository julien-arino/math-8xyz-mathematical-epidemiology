## ----set-lecture-number,echo=FALSE--------------------------------------------
lecture_number = "17"


## ----set-options,echo=FALSE,warning=FALSE,message=FALSE-----------------------
# Source the code common to all lectures
source("common-code.R")


## ----set-slide-background,echo=FALSE,results='asis'---------------------------
# Are we plotting for a dark background? Setting is in common-code.R, but
# cat command must run here.
cat(input_setup)


## -----------------------------------------------------------------------------
pop = c(34.017, 1348.932, 1224.614, 173.593, 93.261) * 1e+06
countries = c("Canada", "China", "India", "Pakistan", "Philippines")
T = matrix(data = c(0, 1268, 900, 489, 200, 
                    1274, 0, 678, 859, 150, 
                    985, 703, 0, 148, 58, 
                    515, 893, 144, 0, 9, 
                    209, 174, 90, 2, 0), 
           nrow = 5, ncol = 5, byrow = TRUE)	


## -----------------------------------------------------------------------------
pop = c(34.017, 1348.932, 1224.614, 173.593, 93.261) * 1e+06
countries = c("Canada", "China", "India", "Pakistan", "Philippines")
death_rates = 1/(365.25*c(81.30, 78.59, 67.74, 66.43, 72.19))
birth_rates = pop*death_rates


## -----------------------------------------------------------------------------
p = list()
p$M = mat.or.vec(nr = dim(T)[1], nc = dim(T)[2])
for (from in 1:5) {
  for (to in 1:5) {
    p$M[to, from] = -log(1 - T[from, to]/pop[from])
  }
  p$M[from, from] = 0
}
p$M = p$M - diag(colSums(p$M))


## -----------------------------------------------------------------------------
p$P = dim(p$M)[1]
p$epsilon = rep((1/1.5), p$P)
p$gamma = rep((1/5), p$P)
p$nu = rep((1/365.25), p$P)
p$b = birth_rates
p$d = death_rates
# The desired values for R_0
R_0 = rep(1.5, p$P)


## -----------------------------------------------------------------------------
p$idx_S = 1:p$P
p$idx_L = (p$P+1):(2*p$P)
p$idx_I = (2*p$P+1):(3*p$P)
p$idx_R = (3*p$P+1):(4*p$P)


## -----------------------------------------------------------------------------
# Set initial conditions. For example, we start with 2
# infectious individuals in Canada.
L0 = mat.or.vec(p$P, 1)
I0 = mat.or.vec(p$P, 1)
R0 = mat.or.vec(p$P, 1)
I0[1] = 2
S0 = pop - (L0 + I0 + R0)
# Vector of initial conditions to be passed to ODE solver.
IC = c(S = S0, L = L0, I = I0, R = R0)
# Time span of the simulation (5 years here)
tspan = seq(from = 0, to = 100, by = 0.1)


## -----------------------------------------------------------------------------
for (i in 1:p$P) {
  p$beta[i] = 
    R_0[i] *(p$gamma[i]+p$d[i]) * (p$epsilon[i]+p$d[i]) * p$d[i] / 
    (p$epsilon[i]*p$d[i])
}


## -----------------------------------------------------------------------------
SLIRS_metapop_rhs <- function(t, x, p) {
	with(as.list(p), {
		S = x[idx_S]
		L = x[idx_L]
		I = x[idx_I]
		R = x[idx_R]
		Phi = beta*S*I
		dS = b - d*S - Phi + M%*%S
		dL = Phi - (epsilon+d)*L + M%*%L
		dI = epsilon*L - (gamma+d)*I + M%*%I
		dR = gamma*I + - (nu+d)*R + M%*%R
		return(list(c(dS, dL, dI, dR)))
	})
}	


## -----------------------------------------------------------------------------
# Call the ODE solver
# sol <- ode(y = IC,
# 			times = tspan,
# 			func = SLIRS_metapop_rhs,
# 			parms = p,
# 			method = "ode45")


## ----convert-Rnw-to-R,warning=FALSE,message=FALSE,echo=FALSE,results='hide'----
rmd_chunks_to_r_temp()

