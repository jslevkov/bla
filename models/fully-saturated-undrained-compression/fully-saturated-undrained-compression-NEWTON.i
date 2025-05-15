# This test loads a saturated block

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
#modelunit_velocity = '${raw ${modelunit_length} / ${modelunit_time} }'

# some constants
gravitational_acceleration = '${units 9.81 m/s^2 -> ${modelunit_acceleration}}'
water_density = '${units 998.2071 kg/m^3 -> ${modelunit_density}}'
water_specific_weight = '${fparse ${water_density} * ${gravitational_acceleration}}'

material_density = '${units 2500 kg/m^3 -> ${modelunit_density} }'

[GlobalParams]
    displacements = 'disp_x disp_y disp_z'
    use_displaced_mesh = false
    PorousFlowDictator = dictator
[]

[Problem]
    solve = true
[]

[Mesh]
    [BaseMesh]
        type = GeneratedMeshGenerator
        subdomain_name = 'BaseMesh'
        elem_type = 'TET10'
        dim = 3
        nx = 6
        ny = 6
        nz = 6
        xmin = -3
        xmax = +3
        ymin = -3
        ymax = +3
        zmin = -3
        zmax = +3
    []
[]

[Variables]
    [disp_x]
        family = LAGRANGE
        order = SECOND
    []
    [disp_y]
        family = LAGRANGE
        order = SECOND
    []
    [disp_z]
        family = LAGRANGE
        order = SECOND
    []
    [porepressure]
        family = LAGRANGE
        order = SECOND
        scaling = 1E+5
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
        type = PorousFlowMassTimeDerivative #why not PorousFlowFullySaturatedMassTimeDerivative
        fluid_component = 0
        variable = 'porepressure'
    []
    [flux]
        type = PorousFlowFullySaturatedDarcyFlow
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

[UserObjects] #necessary when porous flos simulations are performed, This must be present in all simulations!
    [dictator]
        type = PorousFlowDictator
        porous_flow_vars = 'porepressure disp_x disp_y disp_z'
        number_fluid_phases = 1
        number_fluid_components = 1
    []
[]

# ===== AuxVariable & AuxKernel: stress =====
[AuxVariables]
    [stress_xx]
        order = CONSTANT
        family = MONOMIAL
    []
    [stress_yy]
        order = CONSTANT
        family = MONOMIAL
    []
    [stress_zz]
        order = SECOND
        family = MONOMIAL
    []
    [stress_xy]
        order = CONSTANT
        family = MONOMIAL
    []
    [stress_xz]
        order = CONSTANT
        family = MONOMIAL
    []
    [stress_yz]
        order = CONSTANT
        family = MONOMIAL
    []
    [stress_maxprincipal]
        order = CONSTANT
        family = MONOMIAL
    []
    [stress_minprincipal]
        order = CONSTANT
        family = MONOMIAL
    []
[]
[AuxKernels]
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
    [stress_yz]
        type = RankTwoAux
        rank_two_tensor = stress
        index_i = 1
        index_j = 2
        variable = stress_yz
    []
    [stress_xz]
        type = RankTwoAux
        rank_two_tensor = stress
        index_i = 2
        index_j = 0
        variable = stress_xz
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
        order = CONSTANT
        family = MONOMIAL
    []
    [q]
        order = CONSTANT
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

# ===== fix the model boundaries =====
[BCs]

    [left_fix_x]
        type = DirichletBC
        variable = disp_x
        boundary = 'left'
        value = 0.0
    []
    [right_fix_x]
        type = DirichletBC
        variable = disp_x
        boundary = 'right'
        value = 0.0
    []

    [top_fix_y]
        type = DirichletBC
        variable = disp_y
        boundary = 'top'
        value = 0.0
    []
    [bottom_fix_y]
        type = DirichletBC
        variable = disp_y
        boundary = 'bottom'
        value = 0.0
    []

    [front_fix_z]
        type = DirichletBC
        variable = disp_z
        boundary = 'front'
        value = 0.0
    []
    [back_fix_z]
        type = DirichletBC
        variable = disp_z
        boundary = 'back'
        value = 0.0
    []
[]

# lower the model boundary at ZMax with time
[BCs]
    [front_Dirichlet]
        type = FunctionDirichletBC
        variable = disp_z
        boundary = 'front'
        function = 'front_disp_z_function'
    []
[]
[Functions]
    [front_disp_z_function]
        type = ParsedFunction
        expression = '-0.001 * min(10, max(0,t-1))'
    []
[]

# PorousFlowSink at all sides (enforcing no flux)
[BCs]
    [front_pfs]
        type = PorousFlowSink
        boundary = 'left right top bottom front back'
        variable = 'porepressure'
        flux_function = 0.0
    []
[]

# ===== Initial Conditions: Initial Stress Field =====
# due to gravity, the initial stress field is geostatic
[Functions]
    sig_top = '${units 0.0 kN/m^2 -> ${modelunit_pressure} }'
    z_top = 3.0
    K0 = 0.5
    buoyantDensity = '${fparse ${material_density} - ${water_density} }'
    [ini_xx]
        type = ParsedFunction
        expression = '(-sig_top - rho * g * (z_top - z)) * K0'
        symbol_names = 'sig_top     z_top      rho                   g                              K0   '
        symbol_values = '${sig_top}  ${z_top}   ${buoyantDensity}   ${gravitational_acceleration}  ${K0}'
    []
    [ini_yy]
        type = ParsedFunction
        expression = '(-sig_top - rho * g * (z_top - z)) * K0'
        symbol_names = 'sig_top     z_top      rho                   g                              K0   '
        symbol_values = '${sig_top}  ${z_top}   ${buoyantDensity}   ${gravitational_acceleration}  ${K0}'
    []
    [ini_zz]
        type = ParsedFunction
        expression = '(-sig_top - rho * g * (z_top - z))'
        symbol_names = 'sig_top     z_top      rho                   g                               K0  '
        symbol_values = '${sig_top}  ${z_top}   ${buoyantDensity}   ${gravitational_acceleration}   ${K0}'
    []
[]

# ===== Initial Conditions: Pore-Pressure =====
# due to gravity, the initial pore pressure is hydrostatic
[Functions]
    Water_Z_Ref = 3.0
    [func_ini_porepressure]
        type = 'ParsedFunction'
        expression = '(${Water_Z_Ref} - z) * ${water_specific_weight}'
    []
[]
[ICs]
    [porepressure]
        type = FunctionIC
        variable = 'porepressure'
        function = 'func_ini_porepressure'
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

# ===== Material: Volume Elements =====
[Materials]

    # just a linear-elastic material
    [elasticity_tensor]
        type = ComputeIsotropicElasticityTensor
        youngs_modulus = '${units 18 GN/m^2 -> ${modelunit_pressure} }'
        poissons_ratio = 0.25
    []
    [stress]
        type = ComputeFiniteStrainElasticStress
    []

    # initial stresses
    [eigenstrain]
        type = ComputeEigenstrainFromInitialStress
        eigenstrain_name = 'ini_stress'
        initial_stress = 'ini_xx 0 0  0 ini_yy 0  0 0 ini_zz'
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
    [ppss] #as in example undrained_oedometer.i
        type = PorousFlow1PhaseFullySaturated
        porepressure = 'porepressure'
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
        solid_bulk = '${units 12.0 GN/m^2 -> ${modelunit_pressure} }' # K = E / (3 - 6 * nu)
    []
    [permeability]
        type = PorousFlowPermeabilityConst
        permeability = '1E-7 0 0  0 1E-7 0  0 0 1E-7'
    []
[]

[Preconditioning]
    [SMP]
        type = SMP
        full = true

        petsc_options = '-ksp_snes_ew'
        petsc_options_iname = '-ksp_type -pc_type -pc_hypre_type -sub_pc_type -sub_pc_factor_shift_type -sub_pc_factor_levels -ksp_gmres_restart'
        petsc_options_value = ' gmres     hypre    boomeramg      lu           NONZERO                   4                     301'
    []
[]

[Executioner]
    type = Transient
    verbose = true

    solve_type = 'NEWTON'

    line_search = none

    #l_abs_tol = 1E-4
    #l_tol = 1E-5
    l_max_its = 20

    #nl_abs_tol = 1E-8 # 1E2   #1E-3
    #nl_rel_tol = 1E-6 #1e-8
    nl_max_its = 5

    start_time = 0.0
    end_time = 11
    dtmin = 1e-2
    [TimeSteppers]
        [TimeSequenceStepper1]
            type = TimeSequenceStepper
            time_sequence = '1 2 3 4 5 6 7 8 9 10 11'
        []
    []

    [Quadrature]
        type = SIMPSON
        order = SECOND
    []
[]

[Outputs]
    print_linear_residuals = true
    perf_graph = true
    exodus = true
[]

[Debug]
    # check_jacobian = true
    show_top_residuals = 0
    show_var_residual_norms = true
[]
