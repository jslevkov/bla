#include "ExampleIC.h"

registerMooseObject("blaApp", ExampleIC);

InputParameters
ExampleIC::validParams()
{
  InputParameters params = InitialCondition::validParams();
  params.addRequiredParam<Real>("coefficient", "The value of the initial condition");
  return params;
}

ExampleIC::ExampleIC(const InputParameters & parameters)
  : InitialCondition(parameters), _coefficient(getParam<Real>("coefficient"))
{
}

// This is the primary function custom ICs must implement.
Real
ExampleIC::value(const Point & p)
{
  // The Point class is defined in libMesh.  The spatial coordinates x,y,z can be accessed
  // individually using the parenthesis operator and a numeric index from 0..2
  return 2. * _coefficient * std::abs(p(0));
}