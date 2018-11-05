// Secant method root-finder
// Parameters:
//   func: Function to find root (has to take 1 parameter)
//   x0: Ideally braces the root to the left
//   x1: Ideally braces the root to the right
//   maxIter: Max iterations to try
//   tol: Tollerance (on convergence abs(f(x)) < tol)

RUNONCEPATH("/core/lib_ui").

function mathSecantMethod {
  parameter func.
  parameter x0.
  parameter x1.
  parameter maxIter.
  parameter tol.

  LOCAL xnm1 to x0.
  LOCAL xnm2 to x1.

  LOCAL fxnm1 to func(xnm1).
  LOCAL fxnm2 to func(xnm2).

  LOCAL iter to 1.
  until iter > maxIter {
    LOCAL x to xnm1 - fxnm1 * (xnm1 - xnm2) / (fxnm1 - fxnm2).
    LOCAL fx to func(x).

    if abs(fx) < tol {
      return x.
    }

    SET xnm2 to xnm1.
    SET fxnm2 to fxnm1.
    SET xnm1 to x.
    SET fxnm1 to fx.
    SET iter to iter + 1.
  }

  uiFatal("Secant method did not converge").
}
