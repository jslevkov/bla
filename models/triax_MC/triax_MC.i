# This test simulates a undrained consolidated UC triax test with a Mohr-Coulomb Material

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
        elem_type = "TET10"
        dim = 3
        nx = 3
        ny = 3
        nz = 2
        xmin = -6
        xmax = +6
        ymin = -6
        ymax = +6
        zmin = -2
        zmax = +2
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
        scaling = 1E+5 #for a MC-Model should be fine -> later for a Opalinus Material a scaling factor of 1E+9 is to be used
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
        type = PorousFlowMassTimeDerivative
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

# ===== UserObjects for porous flow analysis =====
[UserObjects] #necessary when porous flow simulations are performed, This must be present in all simulations!
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

# ===== Initial Conditions: Initial Stress Field =====
[Functions]
    sig_top = '${units 0.0 kN/m^2 -> ${modelunit_pressure} }'
    z_top = 2.0
    K0 = 0.5

    [ini_xx]
        type = ParsedFunction
        expression = '(-sig_top - rho * g * (z_top - z)) * K0'
        symbol_names = 'sig_top     z_top      rho                   g                               K0  '
        symbol_values = '${sig_top}  ${z_top}   ${material_density}   ${gravitational_acceleration}   ${K0} '
    []
    [ini_yy]
        type = ParsedFunction
        expression = '-sig_top - rho * g * (z_top - z)'
        symbol_names = 'sig_top     z_top      rho                   g                               K0  '
        symbol_values = '${sig_top}  ${z_top}   ${material_density}   ${gravitational_acceleration}   ${K0} '
    []
    [ini_zz]
        type = ParsedFunction
        expression = '(-sig_top - rho * g * (z_top - z)) * K0'
        symbol_names = 'sig_top     z_top      rho                   g                               K0  '
        symbol_values = '${sig_top}  ${z_top}   ${material_density}   ${gravitational_acceleration}   ${K0} '
    []
[]

# ===== Initial Conditions: Pore-Pressure =====
# due to gravity, the initial pore pressure is hydrostatic
[Functions]
    Water_Z_Ref = 2.0
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

# ===== Displacement boundary conditions =====
[BCs]

    [back_fix_x]
        type = DirichletBC
        variable = disp_x
        boundary = 'back'
        value = 0.0
    []

    [back_fix_y]
        type = DirichletBC
        variable = disp_y
        boundary = 'back'
        value = 0.0
    []

    [back_fix_z]
        type = DirichletBC
        variable = disp_z
        boundary = 'back'
        value = 0.0
    []
[]

# ===== Undrained Flow boundary conditions =====
[BCs]
    [front_pfs]
        type = PorousFlowSink
        boundary = 'left right top bottom front back'
        variable = 'porepressure'
        flux_function = 0.0
    []
[]

# ===== Pressure boundary conditions =====
# apply confinement pressures with
[BCs]
    [sig_z]
        type = Pressure
        variable = disp_z
        boundary = 'front'
        function = confinement_z
    []

    [left_sig_x]
        type = Pressure
        variable = disp_x
        boundary = 'left'
        function = confinement_x
    []

    [right_sig_x]
        type = Pressure
        variable = disp_x
        boundary = 'right'
        function = confinement_x
    []

    [top_sig_y]
        type = Pressure
        variable = disp_y
        boundary = 'top'
        function = confinement_y
    []

    [bottom_sig_y]
        type = Pressure
        variable = disp_y
        boundary = 'bottom'
        function = confinement_y
    []
[]

# ===== Functions to be used by the Stages =====
[Functions]

    [confinement_x]
        type = 'StagedFunction'
    []
    [confinement_y]
        type = 'StagedFunction'
    []
    [confinement_z]
        type = 'StagedFunction'
    []
[]

# ===== The Stages-Blocks =====
[Stages]

    [Stage0]
        t = 0.0
        #initialize the stagedFunction

        [Stage0_confinement]
            type = 'StagedFunctionValueChange'
            function_names = 'confinement_x         confinement_y            confinement_z'
            new_values = '    0                     0                        0'
        []
    []

    [Stage1]
        load_x = '${units 1 kN/m^2 -> ${modelunit_pressure} }'
        load_y = '${units 1 kN/m^2 -> ${modelunit_pressure} }'
        load_z = '${units 1 kN/m^2 -> ${modelunit_pressure} }'

        #lets activate the confinement change values from 0 to 1 kN/m^2
        t = 1.0

        [Stage1_confinement]
            type = 'StagedFunctionValueChange'
            start_time = 't - 0.1'
            end_time = 't - 0.0001'
            function_names = 'confinement_x  confinement_y  confinement_z'
            new_values = '    ${load_x}      ${load_y}      ${load_z}'
        []
    []

    [Stage2]
        #lets set the confinement values from 1 to 100 kN/m^2

        load_x = '${units 100 kN/m^2 -> ${modelunit_pressure} }'
        load_y = '${units 100 kN/m^2 -> ${modelunit_pressure} }'
        load_z = '${units 100 kN/m^2 -> ${modelunit_pressure} }'

        t = 2.0

        [Stage2_confinement]
            type = 'StagedFunctionValueChange'
            start_time = 't - 0.1'
            end_time = 't - 0.0001'
            function_names = 'confinement_x  confinement_y   confinement_z'
            new_values = '    ${load_x}      ${load_y}      ${load_z}'
        []
    []

    [Stage3]
        #shearing by increasing vertical load whilst horizontal loads remain 100 kN/m2

        t = 3.0
        load_z = '${units 500 kN/m^2 -> ${modelunit_pressure} }'

        [Stage3_shearing]
            type = 'StagedFunctionValueChange'
            start_time = 't - 0.1'
            end_time = 't - 0.0001'
            function_names = 'confinement_z'
            new_values = '${load_z}'
        []
    []
[]

# ===== Mohr Coulomb specific UserObject: Predefininition of paramters =====
[UserObjects]
    [ts] #tensile stress
        type = SolidMechanicsHardeningConstant
        value = '${units 1e6 N/m^2 -> ${modelunit_pressure} }'
    []
    [cs] #compressive stress
        type = SolidMechanicsHardeningConstant
        value = '${units 1e6 N/m^2 -> ${modelunit_pressure} }'
    []
    [coh] #cohesion
        type = SolidMechanicsHardeningConstant
        value = '${units 1 kN/m^2 -> ${modelunit_pressure} }'
    []
    [angphi] #friction angle
        type = SolidMechanicsHardeningConstant
        value = 30
        convert_to_radians = true
    []
    [angpsi] #dilatancy angle
        type = SolidMechanicsHardeningConstant
        value = 0.001
        convert_to_radians = true
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
    # initial stresses
    [eigenstrain]
        type = ComputeEigenstrainFromInitialStress
        eigenstrain_name = 'ini_stress'
        initial_stress = 'ini_xx 0 0  0 ini_yy 0  0 0 ini_zz'
    []

    # === Mohr Coulomb specific blocks ===
    [elasticity_tensor]
        type = ComputeIsotropicElasticityTensor
        youngs_modulus = '${units 1000 kN/m^2 -> ${modelunit_pressure} }'
        poissons_ratio = 0.25
    []
    [tensile]
        type = CappedMohrCoulombStressUpdate
        tensile_strength = ts
        compressive_strength = cs
        cohesion = coh
        friction_angle = angphi
        dilation_angle = angpsi
        smoothing_tol = '${units 0.001 N/m^2 -> ${modelunit_pressure} }'
        yield_function_tol = 1.0E-12
    []
    [stress]
        type = ComputeMultipleInelasticStress
        inelastic_models = tensile
        perform_finite_strain_rotations = false
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
    solve_type = 'PJFNK'

    petsc_options = '-snes_converged_reason'

    # best overall
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'

    # best if you do not have mumps:
    # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    # petsc_options_value = ' lu       superlu_dist'

    line_search = none

    # tolerances of the (nested) linear solve
    #l_abs_tol = 1e-50
    l_tol = 1e-5
    l_max_its = 10

    # tolerances of the (outer) nonlinear solve
    #nl_abs_tol = 5e-5
    nl_rel_tol = 1e-3
    nl_max_its = 5

    end_time = 4.0
    [TimeSteppers]
        [StagedTimeSequenceStepper1]
            # we use the time steps defined in the Stages-Blocks
            type = StagedTimeSequenceStepper
        []
    []
[]

[Outputs]
    exodus = true
[]

