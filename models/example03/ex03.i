# Example 3: Multiphysics coupling
[Mesh]
    file = 'mug.e'
[]

[Variables]
    [convected]
        order = FIRST # u diffused' variable is approximated with linear Lagrange shape functions.
        family = LAGRANGE
    []

    [diffused]
        order = FIRST
        family = LAGRANGE
    []
[]

[Kernels] #weak form of the problem statement is represented by a Diffusion Kernel object. The Diffusion Kernel is already defined in Moose
    [diff_convected] #A diffusion kernel is defined for the convected variable
        type = Diffusion
        variable = convected #u
    []

    [diff_diffused] #A diffusion kernel is defined for the diffused variable
        type = Diffusion
        variable = diffused #v
    []

    [conv] #the actual coupling of the equations takes place in the ExampleConvection object
        type = ExampleConvection
        variable = convected

        # Couple a variable into the convection kernel using local_name = simulationg_name syntax
        some_variable = diffused
    []
[]

[BCs]
    [bottom_convected] #arbitrary user-chosen name
        type = DirichletBC
        variable = convected
        boundary = 'bottom' #this must match a named boundary in the mesh file
        value = 1
    []

    [top_convected]
        type = DirichletBC
        variable = convected
        boundary = 'top' #this must match a named boundary in the mesh file
        value = 0
    []

    [bottom_diffused] #arbitrary user-chosen name
        type = DirichletBC
        variable = diffused
        boundary = 'bottom' #this must match a named boundary in the mesh file
        value = 2
    []

    [top_diffusedd]
        type = DirichletBC
        variable = diffused
        boundary = 'top' #this must match a named boundary in the mesh file
        value = 0
    []
[]

[Executioner] #type of problem to solve and the method for solving. This problem is steady state and will use the STEADY executioner and will use the default solving method preconditioned Jacobian free newton krylov
    type = Steady
    solve_type = 'PJFNK'
[]

[Outputs]
    execute_on = 'TIMESTEP_END'
    exodus = true
[]