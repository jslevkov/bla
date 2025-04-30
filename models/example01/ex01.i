# Example 1: as simple as it gets
  # We use a pre-generated mesh file (in exodus format).


[Mesh]
    file = 'mug.e'
[]

[Variables]
    [./diffused]
      order = FIRST         # u diffused' variable is approximated with linear Lagrange shape functions.
      family = LAGRANGE
    [../]
  []

[Kernels] #weak form of the problem statement is represented by a Diffusion Kernel object. The Diffusion Kernel is already defined in Moose
  [./diff]
    type = Diffusion
    variable = diffused #previously defined variable
  [../]
  
[]

[BCs]
  [./bottom] #arbitrary user-chosen name
    type = DirichletBC
    variable = diffused
    boundary = 'bottom' #this must match a named boundary in the mesh file 
    value = 1
  [../]

  [./top]
    type = DirichletBC
    variable = diffused
    boundary = 'top' #this must match a named boundary in the mesh file
    value = 0
  [../]

[]

[Executioner] #type of problem to solve and the method for solving. This problem is steady state and will use the STEADY executioner and will use the default solving method preconditioned Jacobian free newton krylov
  type = Steady
  solve_type = 'PJFNK'

[]

[Outputs]
  execute_on = 'TIMESTEP_END'
  exodus = true 

[]

