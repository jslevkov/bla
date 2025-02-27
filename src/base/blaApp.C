#include "blaApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
blaApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

blaApp::blaApp(InputParameters parameters) : MooseApp(parameters)
{
  blaApp::registerAll(_factory, _action_factory, _syntax);
}

blaApp::~blaApp() {}

void
blaApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<blaApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"blaApp"});
  Registry::registerActionsTo(af, {"blaApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
blaApp::registerApps()
{
  registerApp(blaApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
blaApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  blaApp::registerAll(f, af, s);
}
extern "C" void
blaApp__registerApps()
{
  blaApp::registerApps();
}
