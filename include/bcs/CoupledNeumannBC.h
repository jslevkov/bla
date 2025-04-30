#pragma once

#include "IntegratedBC.h"

/// Implements a simple constant Neumann BC where grad(u) = alpha * v on the boundary.

class CoupledNeumannBC : public IntegratedBC
{
public:
  CoupledNeumannBC(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  virtual Real computeQpResidual() override;

private:
  /// Multiplier on the boundary.
  Real _alpha;
  /// reference to a user-specifiable coupled (independent) variable
  const VariableValue & _some_var_val;
};