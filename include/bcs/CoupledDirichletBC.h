#pragma once

#include "NodalBC.h"

/// Implements a coupled Dirichlet BC where u = alpha * some_var on the boundary.
class CoupledDirichletBC : public NodalBC
{
public:
  CoupledDirichletBC(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  virtual Real computeQpResidual() override;

private:
  /// Multiplier on the boundary.
  Real _alpha;
  /// reference to a user-specifiable coupled (independent) variable
  const VariableValue & _some_var_val;
};