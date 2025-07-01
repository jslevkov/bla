# This test simulates an undrained consolidated UC triax test with a Mohr-Coulomb Material

# model units
modelunit_length = 'm'
modelunit_time = 's' #s = seconds, h = hours, day = days
modelunit_mass = 'Mg' # kg = kilograms, Mg = tons; Gg = kilotons

# derived units (this may be moved into a !include)
modelunit_area = '${raw ${modelunit_length} ^ 2}'
modelunit_volume = '${raw ${modelunit_length} ^ 3}'
modelunit_force = '${raw ${modelunit_mass} * ${modelunit_length} / ${modelunit_time} ^ 2}'
modelunit_pressure = '${raw ${modelunit_force} / ${modelunit_area}}'
modelunit_acceleration = '${raw ${modelunit_length} / ${modelunit_time} ^ 2}'
modelunit_density = '${raw ${modelunit_mass} / ${modelunit_volume}}'
modelunit_dynamic_viscosity = '${raw ${modelunit_pressure} * ${modelunit_time}}'
modelunit_strain_rate = '${raw ${modelunit_time} ^ -1}'
modelunit_alpha = '${raw ${modelunit_pressure} ^ -1}'

# some constants
gravitational_acceleration = '${units 9.81 m/s^2 -> ${modelunit_acceleration}}'
water_density = '${units 998.2071 kg/m^3 -> ${modelunit_density}}'
water_specific_weight = '${fparse ${water_density} * ${gravitational_acceleration}}'

material_density = '${units 2500 kg/m^3 -> ${modelunit_density}}'
buoyantDensity = '${fparse ${material_density} - ${water_density} }'

#experiment constants
pconf = '${units 2500 kN/m^2 -> ${modelunit_pressure} }' #2.5 MPa --> the initial effective confining pressure applied to the sample before shearing
pw = '${units 2500 kN/m^2 -> ${modelunit_pressure} }' #2.5 MPa the initial pore pressure before shearing
pconf_total = ${pconf}+${pw} #MPa Total confining presure

strainrate_z = '${units -5.0e-7 1/s -> ${modelunit_strain_rate} }'
sample_h = '${units 0.06 m -> ${modelunit_length} }' #the initial height of the sample
delta_z_rate = '${fparse ${sample_h} * ${strainrate_z} }' #velocity at which specimen is deformed  [m/s]
dip_angle = 90 # P specimen

#damage model constants
damI = 0.001


[GlobalParams]
  displacements = 'disp_x disp_y disp_z' #z is the vertical one
  use_displaced_mesh = false
  PorousFlowDictator = dictator
  biot_coefficient = 1
[]

[Problem]
  solve = true
[]

[Mesh]

  [base]
    type = FileMeshGenerator
    file = 'triax.p3d.e'
    show_info = false
  []

  #[order_conversion]
  #  type = ElementOrderConversionGenerator
  #  input = base
  #  conversion_type = FIRST_ORDER
  #[]

[]

!include triax.p3d.groups.i

boundary = '${Mesh/BoundaryZMin} ${Mesh/BoundaryZMax} ${Mesh/MantleSurfaces}'

[Variables]
  [disp_x]
    family = LAGRANGE
    order = SECOND
    #order = FIRST
  []
  [disp_y]
    family = LAGRANGE
    order = SECOND
    #order = FIRST
  []
  [disp_z]
    family = LAGRANGE
    order = SECOND
    #order = FIRST
  []
  [porepressure]
    family = LAGRANGE
    order = SECOND
    #order = FIRST
    scaling = 1E10
  []
  [nonlocal_var]
    family = LAGRANGE
    order = SECOND
    #order = FIRST
  []
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [all]
        strain = SMALL
        incremental = true
        add_variables = false 
        eigenstrain_names = 'ini_stress'
      []
    []
  []
[]

# ===== Kernels: Gravity =====
[Kernels]
  [gravity]
    type = Gravity
    variable = disp_z
    value = -${gravitational_acceleration}
  []

  [nonlocality] #taken from Kavans u3_p7_damage
  type = ImplicitNonlocal
  length_scale = 0.01
  variable = nonlocal_var
  []
[]




# ===== Kernels: PorousFlow =====
[Kernels]
  [effective_stress_x] #effective stress rather than total stress analysis -> important for triax!
    type = PorousFlowEffectiveStressCoupling
    variable = 'disp_x'
    component = 0
  []

  [effective_stress_y]
    type = PorousFlowEffectiveStressCoupling
    variable = 'disp_y'
    component = 1
  []

  [effective_stress_z]
    type = PorousFlowEffectiveStressCoupling
    variable = 'disp_z'
    component = 2
  []

  [mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = 'porepressure'
  []
  [flux]
    type = PorousFlowAdvectiveFlux
    #type = PorousFlowFullySaturatedDarcyFlow #Kavan benutzt PorousFlowAdvectiveFlux
    variable = 'porepressure'
    fluid_component = 0
    gravity = '0 0 -${gravitational_acceleration}'
  []
  [poro_vol_exp]
    type = PorousFlowMassVolumetricExpansion
    variable = 'porepressure'
    fluid_component = 0
  []
[]

# ===== UserObjects for porous flow analysis =====
[UserObjects] #necessary when porous flow simulations are performed, This must be present in all simulations!
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'porepressure disp_x disp_y disp_z'
    number_fluid_phases = 1
    number_fluid_components = 1
  []

  [pc]
    type = PorousFlowCapillaryPressureVG
    m = 0.38
    alpha = 0.000000000000000000005 # MPa^-1 #'${units 0.05 m^2/MN -> ${modelunit_alpha} }'
  []

  [ucsInitialStress]
    type = CartesianLocalCoordinateSystem
    origin = '0 0 0.06'
    #origin = '0 0 0'
    e1 = '1 0 0'
    e2 = '0 1 0'
  []
  [ucsOpalinusMaterial]
    type = CartesianLocalCoordinateSystem
    dip_direction_degree = '0'
    dip_angle_degree = ${dip_angle}
    dip_option = 'e1_e2_plane_e1_horizontal'
  []

[]

# ===== AuxVariable & AuxKernel: stress =====
[AuxVariables]
  [effective_mean_pressure]
    order = SECOND
    family = MONOMIAL
  []

  [stress_xx]
    order = SECOND
    family = MONOMIAL
  []
  [stress_yy]
    order = SECOND
    family = MONOMIAL
  []
  [stress_zz]
    order = SECOND
    family = MONOMIAL
  []
  [stress_xy]
    order = SECOND
    family = MONOMIAL
  []
  [stress_yx]
    order = SECOND
    family = MONOMIAL
  []
  [stress_xz]
    order = SECOND
    family = MONOMIAL
  []
  [stress_zx]
    order = SECOND
    family = MONOMIAL
  []
  [stress_yz]
    order = SECOND
    family = MONOMIAL
  []
  [stress_zy]
    order = SECOND
    family = MONOMIAL
  []
  [stress_maxprincipal]
    order = SECOND
    family = MONOMIAL
  []
  [stress_minprincipal]
    order = SECOND
    family = MONOMIAL
  []
[]
[AuxKernels]
  [effective_mean_pressure]
    type = RankTwoScalarAux
    rank_two_tensor = stress
    variable = effective_mean_pressure
    scalar_type = hydrostatic
  []

  [stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 0
    index_j = 0
    variable = stress_xx
  []
  [stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 1
    index_j = 1
    variable = stress_yy
  []
  [stress_zz]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 2
    index_j = 2
    variable = stress_zz
  []
  [stress_xy]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 0
    index_j = 1
    variable = stress_xy
  []
  [stress_yx]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 1
    index_j = 0
    variable = stress_yx
  []
  [stress_yz]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 1
    index_j = 2
    variable = stress_yz
  []
  [stress_zy]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 2
    index_j = 1
    variable = stress_zy
  []
  [stress_xz]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 2
    index_j = 0
    variable = stress_xz
  []
  [stress_zx]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 0
    index_j = 2
    variable = stress_zx
  []
  [stress_maxprincipal]
    type = RankTwoScalarAux
    rank_two_tensor = stress
    variable = stress_maxprincipal
    scalar_type = MaxPrincipal
  []
  [stress_minprincipal]
    type = RankTwoScalarAux
    rank_two_tensor = stress
    variable = stress_minprincipal
    scalar_type = MinPrincipal
  []
[]

# ===== AuxVariable & AuxKernel: p & q =====
[AuxVariables]
  [p]
    order = SECOND
    family = MONOMIAL
  []
  [q]
    order = SECOND
    family = MONOMIAL
  []
[]
[AuxKernels]
  [p]
    type = RankTwoScalarAux
    rank_two_tensor = stress
    variable = p
    scalar_type = hydrostatic
  []
  [q]
    type = RankTwoScalarAux
    rank_two_tensor = stress
    variable = q
    scalar_type = vonMisesStress
  []
[]

# ===== Initial Conditions: Pore-Pressure =====
# due to gravity, the initial pore pressure is hydrostatic
[Functions]
  Water_Z_Ref = 0.06 #-> add pore pressure after confinement!
  [func_ini_porepressure]
    type = 'ParsedFunction'
    expression = '(${Water_Z_Ref} - z) * ${water_specific_weight} + ${pw}'
  []
  [func_confinement_pressure]
    type = 'ParsedFunction'
    expression = '(${Water_Z_Ref} - z) * ${material_density} * ${gravitational_acceleration} + ${pconf_total}'
  []

  [ini_xx]
    type = ParsedFunction
    expression = '${pconf} + (0.06 - z) * (${material_density}-${water_density}) * 1.0 * ${gravitational_acceleration}'
    #expression = '(-sig_top - rho * g * (z_top - z)) * K0'
    #symbol_names = 'sig_top     z_top      rho                   g                              K0   '
    #symbol_values = '${sig_top}  ${z_top}   ${buoyantDensity}   ${gravitational_acceleration}  ${K0}'
[]
[ini_yy]
    type = ParsedFunction
    expression = '${pconf} + (0.06 - z) * (${material_density}-${water_density}) * 1.0 * ${gravitational_acceleration}'
    #expression = '(-sig_top - rho * g * (z_top - z)) * K0'
    #symbol_names = 'sig_top     z_top      rho                   g                              K0   '
    #symbol_values = '${sig_top}  ${z_top}   ${buoyantDensity}   ${gravitational_acceleration}  ${K0}'
[]
[ini_zz]
    type = ParsedFunction
    expression = '${pconf} + (0.06 - z) * (${material_density}-${water_density}) * 1.0 * ${gravitational_acceleration}'
    #expression = '(-sig_top - rho * g * (z_top - z))'
    #symbol_names = 'sig_top     z_top      rho                   g                               K0  '
    #symbol_values = '${sig_top}  ${z_top}   ${buoyantDensity}   ${gravitational_acceleration}   ${K0}'
[]


[]
[ICs]
  [porepressure]
    type = FunctionIC
    variable = 'porepressure'
    function = 'func_ini_porepressure'
  []
[]

# ===== Fixed Displacement boundary conditions =====
[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = '${Mesh/BoundaryZMin} ${Mesh/BoundaryZMax}'
    value = 0.0
  []

  [fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = '${Mesh/BoundaryZMin} ${Mesh/BoundaryZMax}'
    value = 0.0
  []

  [fix_z]
    type = DirichletBC
    variable = disp_z
    boundary = '${Mesh/BoundaryZMin}'
    value = 0.0
  []
[]

# ===== Pressure boundary conditions =====
[BCs]
  [sig_z]
    type = Pressure
    variable = disp_x
    boundary = '${Mesh/MantleSurfaces}'
    function = 'func_confinement_pressure'
  []

  [left_sig_x]
    type = Pressure
    variable = disp_y
    boundary = '${Mesh/MantleSurfaces}'
    function = 'func_confinement_pressure'
  []
[]

# ===== Constant strain rate on top (displacement controlled) Displacement boundary conditions =====
[BCs]
  [top_strain]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = '${Mesh/BoundaryZMax}'
    function = strain_z
  []
[]

# ===== Undrained Flow boundary conditions =====
[BCs]
  [front_pfs]
    type = PorousFlowSink
    boundary = '${boundary}'
    variable = 'porepressure'
    flux_function = 0.0
  []
[]

# ===== Material: Fluid Properties =====
[FluidProperties]
  [simple_fluid]
    type = SimpleFluidProperties
    bulk_modulus = '${units 2.2 GPa -> ${modelunit_pressure} }'
    density0 = '${water_density}'
    thermal_expansion = 0
    viscosity = '${units 0.9 mPa*s -> ${modelunit_dynamic_viscosity} }'
  []
[]

[Functions]
  [strain_z]
    type = 'StagedFunction'
  []
[]

# ===== The Stages-Blocks =====
[Stages]

  [Stage0]
    t = 0.0
    #initialize the stagedFunction
    #initial stage is activated here
    [Stage0_initial]
      type = 'StagedFunctionValueChange'
      function_names = 'strain_z'
      new_values = '0'
    []
  []

  [Stage1]
    t = 1.0
    #dummy stage to check the deformation after initial state
  []

  [Stage2]
    #shearing by introducing strain rate at the top of the specimen (at z_max)

    t = 30000

    delta_z = '${fparse ${delta_z_rate} * t }' #enforced deformation at the end of the time-step

    [Stage2_shearing]
      type = 'StagedFunctionValueChange'
      start_time = '' #empty start_time -> start_time is the endtime of the last stage
      end_time = 't - 0'
      step_function_type = LINEAR
      function_names = 'strain_z'
      new_values = '${delta_z}'
    []

    [Stage2_AdditionalTimeSteps]
      type = StagedAdditionalTimeStep
      #time = 't-5; t-2; t-1; t-0.5'
      #count = 10
      delta_time = 500
    []
  []
[]

# ===== Material: Volume Elements =====
[Materials]

  # initial stresses
  #[ini_stress]
  #  type = ComputeEigenstrainFromGeostaticInitialStress
  #  eigenstrain_name = 'ini_stress'
  #  local_coordinate_system = 'ucsInitialStress'
  #  principal_stress_1 = ${pconf} #effective confining stress
  #  principal_stress_2 = ${pconf}
  #  principal_stress_3 = ${pconf}
  #  stress_1_increment_z = '${fparse ${buoyantDensity} * -1.0 * ${gravitational_acceleration}}' # density * K_0 * gravity
  #  stress_2_increment_z = '${fparse ${buoyantDensity} * -1.0 * ${gravitational_acceleration}}' # density * K_0 * gravity
  #  stress_3_increment_z = '${fparse ${buoyantDensity} * -1.0 * ${gravitational_acceleration}}' # density * 1.0 * gravity
  #[]

  [eigenstrain]
    type = ComputeEigenstrainFromInitialStress
    eigenstrain_name = 'ini_stress'
    initial_stress = 'ini_xx 0 0  0 ini_yy 0  0 0 ini_zz'
[]

  [elasticity_tensor]
    type = OpalinusElasticityTensor
    youngs_modulus_in_plane =  '${units 11 GPa -> ${modelunit_pressure} }'
    youngs_modulus_normal = '${units 6 GPa -> ${modelunit_pressure} }'
    poisson_ratio_in_plane = 0.15
    poisson_ratio_normal = 0.25
    shear_module_normal = '${units 2.4 GPa -> ${modelunit_pressure} }'
    local_coordinate_system = 'ucsOpalinusMaterial'
  []

  #[opalinus]
  #  type = OpalinusPerfectPlasticStressUpdate
  #  local_coordinate_system = 'ucsOpalinusMaterial'
  #  gamma_mean = 0.9
  #  parameter_omega_1 = 0.15
  #  parameter_b_1 = 6.7
  #  p_tensile = '${units 6 MPa -> ${modelunit_pressure} }'
  #  Fs_function_power = -0.25 #by default it is -0.25
#
  #  yield_function_tol = 1e-3
  #  smoothing_tol = 0.0
  #  tip_smoother = '${units 2.0 MPa -> ${modelunit_pressure} }'
  #  min_step_size = 0.004
  #  max_NR_iterations = 40
  #[]


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

  # material density (undrained)
  [undrained_density_0]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = '${material_density}'
  []

  # porous flow
  [temperature]
    type = PorousFlowTemperature
  []

  [eff_fluid_pressure] #as in example undrained_oedometer.i
    type = PorousFlowEffectiveFluidPressure
  []
  [vol_strain] #as in example undrained_oedometer.i
    type = PorousFlowVolumetricStrain
  []

  #[ppss] #as in example undrained_oedometer.i
  #  type = PorousFlow1PhaseFullySaturated
  #  porepressure = 'porepressure'
  #[]

  [ppss]
    type = PorousFlow1PhaseP #why necessary if it is fully saturated?
    porepressure = porepressure
    capillary_pressure = pc
  []

  [massfrac] #as in example undrained_oedometer.i
    type = PorousFlowMassFraction
  []
  [simple_fluid] #as in example undrained_oedometer.i
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid
    phase = 0
  []
  [porosity_bulk] #as in example undrained_oedometer.i
    type = PorousFlowPorosity
    fluid = true
    mechanical = true
    ensure_positive = true
    porosity_zero = 0.11
    solid_bulk = '${units 7.333 GN/m^2 -> ${modelunit_pressure} }' # K = E / (3 - 6 * nu)
  []
  [permeability]
    type = OpalinusPermeabilityTensor
    permeability1 = 5e-19
    permeability2 = 5e-19
    permeability3 = 5e-19
    local_coordinate_system = 'ucsOpalinusMaterial'
  []

  [relperm0] #added from Kavan
    type = PorousFlowRelativePermeabilityCorey
    n = 1
    phase = 0
  []

[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true

    petsc_options = '-ksp_snes_ew'
    #petsc_options_iname = '-ksp_type -pc_type -pc_hypre_type -sub_pc_type -sub_pc_factor_shift_type -sub_pc_factor_levels -ksp_gmres_restart'
    #petsc_options_value = ' gmres     hypre    boomeramg      lu           NONZERO                   4                     301'
  []
[]

[Executioner]
  type = Transient
  #solve_type = 'PJFNK'
  solve_type = 'NEWTON'

  petsc_options = '-snes_converged_reason'

  # best overall
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       mumps'

  # best if you do not have mumps:
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = ' lu       superlu_dist'

  line_search = none

  # tolerances of the (nested) linear solve
  l_abs_tol = 3E-5 #1e-50
  l_tol = 1e-3
  l_max_its = 10

  # tolerances of the (outer) nonlinear solve
  nl_abs_tol = 3E-5 #  5e-5
  nl_rel_tol = 1e-4
  nl_max_its = 15

  end_time = 30000
  [TimeSteppers]
    [StagedTimeSequenceStepper1]
      type = StagedTimeSequenceStepper
    []
  []
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
  csv = true
[]

[Debug]
  show_var_residual_norms = true
[]

[Postprocessors]
  [time_ref]
    type = TimePostprocessor
  []

  [ActivePorePressure]
    type = ElementAverageValue
    variable = porepressure
  []

  #[uz]
  #  type = ElementAverageValue
  #  variable = disp_z
  #[]

  [EffectiveMeanStress]
    type = ElementAverageValue
    variable = p
  []

  [DeviatoricVonMises]
    type = ElementAverageValue
    variable = q
  []

  [PrincipalStress1]
    type = ElementAverageValue
    variable = stress_maxprincipal
  []

  [PrincipalStress3]
    type = ElementAverageValue
    variable = stress_minprincipal
  []

  [EffectiveStressXX]
    type = ElementAverageValue
    variable = stress_xx
  []

  [EffectiveStressYY]
    type = ElementAverageValue
    variable = stress_yy
  []

  [EffectiveStressZZ]
    type = ElementAverageValue
    variable = stress_zz
  []



  #[sigma_xx_z06]
  #  type = PointValue
  #  point = '0 0 0.06'
  #  variable = stress_xx
  #[]
  #
  #[sigma_yy_z06]
  #  type = PointValue
  #  point = '0 0 0.06'
  #  variable = stress_yy
  #[]
  #
  #[sigma_zz_z06]
  #  type = PointValue
  #  point = '0 0 0.06'
  #  variable = stress_zz
  #[]
  #
  #[q_z06]
  #  type = PointValue
  #  point = '0 0 0.06'
  #  variable = q
  #[]
  #
  #[p_z06]
  #  type = PointValue
  #  point = '0 0 0.06'
  #  variable = p
  #[]
  #
  #[porepressure_z06]
  #  type = PointValue
  #  point = '0 0 0.06'
  #  variable = porepressure
  #[]
  #
  [uz]
    type = PointValue
    point = '0 0 0.06'
    variable = disp_z
  []
  #
  #[sigma1_z06]
  #  type = PointValue
  #  point = '0 0 0.06'
  #  variable = stress_maxprincipal
  #[]
  #
  #[sigma3_z06]
  #  type = PointValue
  #  point = '0 0 0.06'
  #  variable = stress_minprincipal
  #[]
  #
  #[sigma_xx_z045]
  #  type = PointValue
  #  point = '0 0 0.045'
  #  variable = stress_xx
  #[]
  #
  #[sigma_yy_z045]
  #  type = PointValue
  #  point = '0 0 0.045'
  #  variable = stress_yy
  #[]
  #
  #[sigma_zz_z045]
  #  type = PointValue
  #  point = '0 0 0.045'
  #  variable = stress_zz
  #[]
  #
  #[q_z045]
  #  type = PointValue
  #  point = '0 0 0.045'
  #  variable = q
  #[]
  #
  #[p_z045]
  #  type = PointValue
  #  point = '0 0 0.045'
  #  variable = p
  #[]
  #
  #[porepressure_z045]
  #  type = PointValue
  #  point = '0 0 0.045'
  #  variable = porepressure
  #[]
  #
  #[disp_z_z045]
  #  type = PointValue
  #  point = '0 0 0.045'
  #  variable = disp_z
  #[]
  #
  #[sigma1_z045]
  #  type = PointValue
  #  point = '0 0 0.045'
  #  variable = stress_maxprincipal
  #[]
  #
  #[sigma3_z045]
  #  type = PointValue
  #  point = '0 0 0.045'
  #  variable = stress_minprincipal
  #[]
  #
  #[msigma_xx_z03]
  #  type = PointValue
  #  point = '0 0 0.03'
  #  variable = stress_xx
  #[]
  #
  #[sigma_yy_z03]
  #  type = PointValue
  #  point = '0 0 0.03'
  #  variable = stress_yy
  #[]
  #
  #[sigma_zz_z03]
  #  type = PointValue
  #  point = '0 0 0.03'
  #  variable = stress_zz
  #[]
  #
  #[q_z03]
  #  type = PointValue
  #  point = '0 0 0.03'
  #  variable = q
  #[]
  #
  #[p_z03]
  #  type = PointValue
  #  point = '0 0 0.03'
  #  variable = p
  #[]
  #
  #[porepressure_z03]
  #  type = PointValue
  #  point = '0 0 0.03'
  #  variable = porepressure
  #[]
  #
  #[disp_z_z03]
  #  type = PointValue
  #  point = '0 0 0.03'
  #  variable = disp_z
  #[]
  #
  #[sigma1_z03]
  #  type = PointValue
  #  point = '0 0 0.03'
  #  variable = stress_maxprincipal
  #[]
  #
  #[sigma3_z03]
  #  type = PointValue
  #  point = '0 0 0.03'
  #  variable = stress_minprincipal
  #[]
  #
  #[sigma_xx_z015]
  #  type = PointValue
  #  point = '0 0 0.015'
  #  variable = stress_xx
  #[]
  #
  #[sigma_yy_z015]
  #  type = PointValue
  #  point = '0 0 0.015'
  #  variable = stress_yy
  #[]
  #
  #[sigma_zz_z015]
  #  type = PointValue
  #  point = '0 0 0.015'
  #  variable = stress_zz
  #[]
  #
  #[q_z015]
  #  type = PointValue
  #  point = '0 0 0.015'
  #  variable = q
  #[]
  #
  #[p_z015]
  #  type = PointValue
  #  point = '0 0 0.015'
  #  variable = p
  #[]
  #
  #[porepressure_z015]
  #  type = PointValue
  #  point = '0 0 0.015'
  #  variable = porepressure
  #[]
  #
  #[disp_z_z015]
  #  type = PointValue
  #  point = '0 0 0.015'
  #  variable = disp_z
  #[]
  #
  #[sigma1_z015]
  #  type = PointValue
  #  point = '0 0 0.015'
  #  variable = stress_maxprincipal
  #[]
  #
  #[sigma3_z015]
  #  type = PointValue
  #  point = '0 0 0.015'
  #  variable = stress_minprincipal
  #[]
  #
  #[sigma_xx_z0]
  #  type = PointValue
  #  point = '0 0 0'
  #  variable = stress_xx
  #[]
  #
  #[sigma_yy_z0]
  #  type = PointValue
  #  point = '0 0 0'
  #  variable = stress_yy
  #[]
  #
  #[sigma_zz_z0]
  #  type = PointValue
  #  point = '0 0 0'
  #  variable = stress_zz
  #[]
  #
  #[q_z0]
  #  type = PointValue
  #  point = '0 0 0'
  #  variable = q
  #[]
  #
  #[p_z0]
  #  type = PointValue
  #  point = '0 0 0'
  #  variable = p
  #[]
  #
  #[porepressure_z0]
  #  type = PointValue
  #  point = '0 0 0'
  #  variable = porepressure
  #[]
  #
  #[disp_z_z0]
  #  type = PointValue
  #  point = '0 0 0'
  #  variable = disp_z
  #[]
  #
  #[sigma1_z0]
  #  type = PointValue
  #  point = '0 0 0'
  #  variable = stress_maxprincipal
  #[]
  #
  #[sigma3_z0]
  #  type = PointValue
  #  point = '0 0 0'
  #  variable = stress_minprincipal
  #[]
[]
