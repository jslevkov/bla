# Example 2: Adding a custom Kernel to example 1
[Mesh]
    file = 'mug.e'
[]

[Variables]
    [convected]
        order = FIRST # u diffused' variable is approximated with linear Lagrange shape functions.
        family = LAGRANGE
    []
[]

[Kernels] #weak form of the problem statement is represented by a Diffusion Kernel object. The Diffusion Kernel is already defined in Moose
    [diff]
        type = Diffusion
        variable = convected #
    []
    [conv]
        type = ExampleConvection
        variable = convected
        velocity = '0.0 0.0 1.0'
    []
[]

[BCs]
    [bottom] #arbitrary user-chosen name
        type = DirichletBC
        variable = convected
        boundary = 'bottom' #this must match a named boundary in the mesh file
        value = 1
    []

    [top]
        type = DirichletBC
        variable = convected
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