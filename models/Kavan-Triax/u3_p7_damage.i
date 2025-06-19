
pconf = 13
pw = 9
pconf_total = 14
dip_angle = 60
damI = 0.001

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  PorousFlowDictator = dictator
  biot_coefficient = 1
[]

[Problem]
  solve = true
[]

[Mesh]
  [file]
    type = FileMeshGenerator
    file = sample3d.msh
    show_info = true
  []
[]

[Variables]
  [disp_x]
    scaling = 1E-3
  []
  [disp_y]
  []
  [disp_z]
    scaling = 1E-3
  []
  [porepressure]
    scaling = 1E-3
  []
  [nonlocal_var]
  []
[]

[ICs]
  [porepressure]
    type = FunctionIC
    variable = porepressure
    function = ini_pp
  []

  [stress_xx]
    type = FunctionIC
    variable = stress_xx
    function = ini_xx
  []
  [stress_yy]
    type = FunctionIC
    variable = stress_yy
    function = ini_yy
  []
  [stress_zz]
    type = FunctionIC
    variable = stress_zz
    function = ini_zz
  []
[]

[Kernels]
  [TensorMechanics] # Small strain
    strain = Small
    displacements = 'disp_x disp_y disp_z'
    use_displaced_mesh = false
    volumetric_locking_correction = true
    add_variables = true
    incremental = true
  []

  [nonlocality]
    type = ImplicitNonlocal
    length_scale = 0.01
    variable = nonlocal_var
  []

  [poro_x]
    type = PorousFlowEffectiveStressCoupling
    use_displaced_mesh = false
    variable = disp_x
    component = 0
  []
  [poro_y]
    type = PorousFlowEffectiveStressCoupling
    use_displaced_mesh = false
    variable = disp_y
    component = 1
  []
  [poro_z]
    type = PorousFlowEffectiveStressCoupling
    use_displaced_mesh = false
    variable = disp_z
    component = 2
  []
  [mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = porepressure
  []
  [flux]
    type = PorousFlowAdvectiveFlux
    use_displaced_mesh = false
    variable = porepressure
    gravity = '0 0 0'
    fluid_component = 0
  []
  [poro_vol_exp]
    type = PorousFlowMassVolumetricExpansion
    variable = porepressure
    fluid_component = 0
  []
[]

[AuxVariables]
  [effective_mean_pressure]
    family = MONOMIAL
    order = CONSTANT
    initial_condition = ${pconf}
  []
  [deviatoric_stress]
    family = MONOMIAL
    order = CONSTANT
    initial_condition = 0
  []
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
  []

  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
  []

  [stress_zz]
    order = CONSTANT
    family = MONOMIAL
  []

  [total_strain_zz]
    order = CONSTANT
    family = MONOMIAL
  []

  [intnl]
    order = CONSTANT
    family = MONOMIAL
  []

  [damage_index]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [effective_mean_pressure]
    type = ParsedAux
    args = 'stress_xx stress_yy stress_zz porepressure'
    function = '-(stress_xx+stress_yy+stress_zz)/3'
    variable = effective_mean_pressure
    execute_on = 'INITIAL TIMESTEP_BEGIN TIMESTEP_END'
  []

  [deviatoric_stress]
    type = ParsedAux
    args = 'stress_xx stress_yy stress_zz '
    function = '(stress_xx^2+stress_yy^2+stress_zz^2-stress_xx*stress_yy-stress_xx*stress_zz-stress_yy*stress_zz)^0.5'
    variable = deviatoric_stress
    execute_on = 'INITIAL TIMESTEP_BEGIN TIMESTEP_END'
  []

  [stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
    execute_on = 'INITIAL TIMESTEP_BEGIN TIMESTEP_END'
  []

  [stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 1
    index_j = 1
    execute_on = 'INITIAL TIMESTEP_BEGIN TIMESTEP_END'
  []

  [stress_zz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_zz
    index_i = 2
    index_j = 2
    execute_on = 'INITIAL TIMESTEP_BEGIN TIMESTEP_END'
  []

  [total_strain_zz]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = total_strain_zz
    index_i = 2
    index_j = 2
    execute_on = timestep_end
  []

  [intnl]
    type = MaterialStdVectorAux
    property = plastic_internal_parameter
    index = 0
    variable = intnl
  []

  [damage_index]
    type = MaterialRealAux
    variable = damage_index
    property = damage_index
    execute_on = timestep_end
  []
[]

[BCs]

  [side1]
    type = ADPressure
    boundary = 'baghal'
    variable = 'disp_x'
    component = 0
    function = ${pconf_total}
  []
  [side2]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = 'bala'
    function = '-3e-9*t'
  []
  [side3]
    type = ADPressure
    boundary = 'baghal'
    variable = 'disp_y'
    component = 1
    function = ${pconf_total}
  []
  [no_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'bala zir'
    value = 0.0
  []
  [no_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'zir'
    value = 0.0
  []
  [no_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'bala zir'
    value = 0.0
  []

  [base]
    type = PorousFlowSink
    boundary = 'baghal bala zir'
    flux_function = 0
    variable = porepressure
  []
[]

[Functions]
  [ini_pp]
    type = ParsedFunction
    vars = 'p0'
    vals = ${pw}
    value = 'p0'
  []

  [ini_xx]
    type = ParsedFunction
    vars = 'sig1'
    vals = -${pconf}
    value = 'sig1'
  []
  [ini_yy]
    type = ParsedFunction
    vars = 'sig2'
    vals = -${pconf}
    value = 'sig2'
  []
  [ini_zz]
    type = ParsedFunction
    vars = 'sig3'
    vals = -${pconf}
    value = 'sig3'
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'porepressure disp_x disp_y disp_z'
    number_fluid_phases = 1
    number_fluid_components = 1
  []
  [pc]
    type = PorousFlowCapillaryPressureVG
    m = 0.38
    alpha = 0.000000000000000000005 # MPa^-1
  []
  [ucsInitialStress]
    type = CartesianLocalCoordinateSystem
    e1 = '1 0 0'
    e2 = '0 1 0'
  []
  [ucsOpalinusMaterial]
    type = CartesianLocalCoordinateSystem
    dip_direction_degree = 0
    dip_angle_degree = ${dip_angle}
    dip_option = 'e1_e2_plane_e1_horizontal'
  []
[]

[Modules]
  [FluidProperties]
    [simple_fluid]
      type = SimpleFluidProperties
      bulk_modulus = 2E3
      density0 = 1000
      thermal_expansion = 0
      viscosity = 9.0E-10 #MPas-2.1e-12exp(1808/T)-T=298
    []
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
  []
  [eff_fluid_pressure]
    type = PorousFlowEffectiveFluidPressure
  []
  [vol_strain]
    type = PorousFlowVolumetricStrain
  []
  [ppss]
    type = PorousFlow1PhaseP
    porepressure = porepressure
    capillary_pressure = pc
  []
  [massfrac]
    type = PorousFlowMassFraction
  []
  [simple_fluid]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid
    phase = 0
  []
  [porosity_bulk]
    type = PorousFlowPorosity
    fluid = true
    mechanical = true
    ensure_positive = true
    porosity_zero = 0.11
    solid_bulk = 1.3333E10
  []

  [permeability_bulk]
    type = PorousFlowPermeabilityConst
    permeability = '1e-20 0 0 0 1e-20 0 0 0 1e-20'
  []
  [relperm0]
    type = PorousFlowRelativePermeabilityCorey
    n = 1
    phase = 0
  []

  [elasticity_tensor]
    type = OpalinusElasticityTensor
    youngs_modulus_in_plane = 11000
    youngs_modulus_normal = 6000
    poisson_ratio_in_plane = 0.15
    poisson_ratio_normal = 0.25
    shear_module_normal = 2000
    local_coordinate_system = 'ucsOpalinusMaterial'
  []

  [strain]
    type = ComputeIncrementalStrain
    volumetric_locking_correction = true
    eigenstrain_names = ini_stress
  []
  [ini_stress]
    type = ComputeEigenstrainFromInitialStress
    eigenstrain_name = ini_stress
    initial_stress = 'ini_xx 0 0  0 ini_yy 0  0 0 ini_zz'
  []

  [damage]
    type = OpalinusDamage
    parameter_damageI = ${damI} #post peak model epsilon_m
    parameter_damageF = 0.002 #post peak model epsilon_f
    parameter_damageA = 1 #old pd3
    omega = 0.85 #post peak model omega
    nonlocal_variable = nonlocal_var
  []

  [kavan]
    type = DesaiHardeningStressUpdate
    gamma_mean = 0.86 #anisotropic strength model
    parameter_omega_1 = 0.2 #anisotropic strength model c1
    parameter_b_1 = 5 #anisotropic strength model c2
    p_tensile = 6 #plastic model sigma_ten
    lode_angle_coefficient = 0.6 #plastic model beta_2
    yield_function_tol = 1e-3
    smoothing_tol = 0.0
    tip_smoother = 0.0
    max_NR_iterations = 100
    min_step_size = 0.04
    nonlocal_variable = nonlocal_var
    parameter_damageI = ${damI}
    parameter_damageF = 0.002 #post peak model epsilon_f
    parameter_gammar = 0.12 #post peak model gamma_r
    local_coordinate_system = 'ucsOpalinusMaterial'
  []

  [stress]
    type = ComputeMultipleInelasticStress
    inelastic_models = 'kavan'
    perform_finite_strain_rotations = false
    tangent_operator = 'nonlinear'
    damage_model = damage
  []

  [undrained_density_0]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = 2500
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  #automatic_scaling = true
  #compute_scaling_once=false
  solve_type = 'NEWTON'

  petsc_options = '-snes_converged_reason'

  # best overall
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       mumps'

  # best if you do not have mumps:
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = ' lu       superlu_dist'

  # best if you do not have mumps or superlu_dist:
  #petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart'
  #petsc_options_value = ' asm      2              lu            gmres     200'

  # very basic:
  #petsc_options_iname = '-pc_type -ksp_type -ksp_gmres_restart'
  #petsc_options_value = ' bjacobi  gmres     200'

  line_search = none

  nl_abs_tol = 5e-6
  nl_rel_tol = 1e-12

  l_max_its = 30
  nl_max_its = 10

  start_time = 0.0
  dt = 5000
  end_time = 300000 #0.5
[]

[Outputs]
  interval = 1
  print_linear_residuals = true
  csv = true
  exodus = true
  checkpoint = true
[]
