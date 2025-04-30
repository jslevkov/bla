#[Problem]
#   solve = false
#[]

# ===== Mesh =====
[Mesh]
    [gmg]
        type = GeneratedMeshGenerator   # Can generate simple lines, rectangles and rectangular prisms
        dim = 2                         # Dimension of the mesh
        nx = 100                        #number of element units in y direction
        ny = 10                         #number of element units in y direction
        xmax = 0.304                       #length of test chamber
        ymax = 0.0257                       #Test chamber radius
    []
    coord_type = 'RZ'                   # Axisymmetric RZ (for the pipe)
    rz_coord_axis = 'X'                 # which axis the symmetry is around
[]


[Variables]
  [pressure] #name that I give
  # Adds a Linear Lagrange variable by default
  []
[]

#Kernels represents the Physics used in the system (the equation)
[Kernels]
  [diffusion]
    type = ADDiffusion                  #Diffusion Kernel that supports aumatic differentiation
    variable = pressure                 #the pressure variable that was created in line 20, ATTENTION ITS CASE SENSITIVE!
    
  []
[]

#to solve a physicial equation (specified in the kernel) we need boundary conditions:
[BCs]
  [inlet] #these names are user-defined
    type = DirichletBC  #simple u=value BC
    variable = pressure #variable to be set
    boundary = left     #name of the sideset in the mesh
    value = 4000        # (Pa) 
    
  []

  [outlet]
    type = DirichletBC
    variable = pressure
    boundary = right
    value = 0           #(Pa)
    
  []
    

[]


[Problem] #main executor of everything
  type = FEProblem #usually used
[]

[Executioner] #solves the problem
  type = Steady
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type' #PETSc option pairs with values below
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  exodus = true #output exodus format

[]

# [Variables]
#   [dummy]
#   []
# []
# 
# [Executioner]
#     type = Transient
# []
# 
# [Outputs]
#     exodus = true
# []