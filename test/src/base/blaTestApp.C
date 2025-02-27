//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "blaTestApp.h"
#include "blaApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
blaTestApp::validParams()
{
  InputParameters params = blaApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

blaTestApp::blaTestApp(InputParameters parameters) : MooseApp(parameters)
{
  blaTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

blaTestApp::~blaTestApp() {}

void
blaTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  blaApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"blaTestApp"});
    Registry::registerActionsTo(af, {"blaTestApp"});
  }
}

void
blaTestApp::registerApps()
{
  registerApp(blaApp);
  registerApp(blaTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
blaTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  blaTestApp::registerAll(f, af, s);
}
extern "C" void
blaTestApp__registerApps()
{
  blaTestApp::registerApps();
}
