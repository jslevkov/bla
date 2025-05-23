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
#modelunit_velocity = '${raw ${modelunit_length} / ${modelunit_time} }'
modelunit_strain_rate = '${raw ${modelunit_time} ^ -1}'

# some constants
gravitational_acceleration = '${units 9.81 m/s^2 -> ${modelunit_acceleration}}'
water_density = '${units 998.2071 kg/m^3 -> ${modelunit_density}}'
water_specific_weight = '${fparse ${water_density} * ${gravitational_acceleration}}'

material_density = '${units 2500 kg/m^3 -> ${modelunit_density}}'

#experiment constants
pconf = '${units 2500 kN/m^2 -> ${modelunit_pressure} }' #2.5 MPa --> the initial effective confining pressure applied to the sample before shearing
pw = '${units 2500 kN/m^2 -> ${modelunit_pressure} }' #2.5 MPa the initial pore pressure before shearing
pconf_total = ${pconf}+${pw} #MPa Total confining presure
# dip_angle = 90
strainrate_z = '${units -5.0e-7 1/s -> ${modelunit_strain_rate} }'
sample_h = '${units 0.06 m -> ${modelunit_length} }' #the initial height of the sample
delta_z_rate = '${fparse ${sample_h} * ${strainrate_z} }' #velocity at which specimen is deformed  [m/s]

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
    [file]
        type = FileMeshGenerator
        file = triax.p3d.e
        show_info = false
    []
    second_order = true
    # construct_side_list_from_node_list = true
[]

!include Triax.p3d.groups.i

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
        scaling = 1E12 #for a MC-Model should be fine -> later for a Opalinus Material a scaling factor of 1E+9 is to be used
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
    [ucsInitialStress]
        type = CartesianLocalCoordinateSystem
        origin = '0 0 0.06'
        e1 = '1 0 0'
        e2 = '0 1 0'
    []
[]

# ===== AuxVariable & AuxKernel: stress =====
[AuxVariables]
    [effective_mean_pressure]
        family = MONOMIAL
        order = CONSTANT
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
    [effective_mean_pressure]
        type = RankTwoScalarAux
        rank_two_tensor = stress
        variable = effective_mean_pressure
        scalar_type = hydrostatic
        execute_on = 'TIMESTEP_BEGIN'
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

# ===== Initial Conditions: Pore-Pressure =====
# due to gravity, the initial pore pressure is hydrostatic
[Functions]
    Water_Z_Ref = 0.06 #-> add pore pressure after confinement!
    [func_ini_porepressure]
        type = 'ParsedFunction'
        expression = '(${Water_Z_Ref} - z) * ${water_specific_weight} + ${pw}'
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
    [ZMin_fix_x]
        type = DirichletBC
        variable = disp_x
        boundary = '${Mesh/BoundaryZMin} ${Mesh/BoundaryZMax}'
        value = 0.0
    []

    [ZMin_fix_y]
        type = DirichletBC
        variable = disp_y
        boundary = '${Mesh/BoundaryZMin} ${Mesh/BoundaryZMax}'
        value = 0.0
    []

    [ZMin_fix_z]
        type = DirichletBC
        variable = disp_z
        boundary = '${Mesh/BoundaryZMin}'
        value = 0.0
    []
[]

# ===== Undrained Flow boundary conditions =====
[BCs]
    [front_pfs]
        type = PorousFlowSink
        boundary = '${Mesh/MantleSurfaces} ${Mesh/BoundaryZMax} ${Mesh/BoundaryZMin}'
        variable = 'porepressure'
        flux_function = 0.0
    []
[]

# ===== Constant strain rate on top (displacement controlled) Displacement boundary conditions =====
[BCs]
    [top_strain]
        type = FunctionDirichletBC
        variable = disp_z
        boundary = 'BoundaryZMax'
        function = strain_z
    []
[]

# ===== Pressure boundary conditions =====
[BCs]
    [sig_z]
        type = Pressure
        variable = disp_x
        boundary = '${Mesh/MantleSurfaces}'
        function = ${pconf_total}
    []

    [left_sig_x]
        type = Pressure
        variable = disp_y
        boundary = '${Mesh/MantleSurfaces}'
        function = ${pconf_total}
    []
[]

# ===== Functions to be used by the Stages =====
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

    #[Stage0plus]
    #    t = 1.0
    #    #dummy stage to check the deformation after initial state
    #[]

    #[Stage1]
    #shearing by introducing strain rate at the top of the speciment (at z_max)

    #    t = 1.0
    #    delta_z = '${fparse ${delta_z_rate} * t }' #enforced deformation at the end of the time-step

    #    [Stage1_shearing]
    #        type = 'StagedFunctionValueChange'
    #        start_time = ''
    #        end_time = 't - 0'
    #        step_function_type = LINEAR
    #        function_names = 'strain_z'
    #        new_values = '${delta_z}'
    #    []
    #    [Stage1_AdditionalTimeStep1]
    #        type = StagedAdditionalTimeStep
    #        time = 't - 0.5'
    #   []
    #[]

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
            delta_time = 100
        []
    []
[]

# ===== Mohr Coulomb specific UserObject: Predefininition of paramters =====
[UserObjects]
    [ts] #tensile stress
        type = SolidMechanicsHardeningConstant
        value = '${units 1e14 kN/m^2 -> ${modelunit_pressure} }'
    []
    [cs] #compressive stress
        type = SolidMechanicsHardeningConstant
        value = '${units 1e14 kN/m^2 -> ${modelunit_pressure} }' #must be larger than the initial effective confining pressure > 2.5 MPa!
    []
    [coh] #cohesion
        type = SolidMechanicsHardeningConstant
        value = '${units 7 MN/m^2 -> ${modelunit_pressure} }' #taken from Vergleichsberechnungen Tabelle 4.3 Rechenwert
    []
    [angphi] #friction angle
        type = SolidMechanicsHardeningConstant
        value = 30 #taken from Vergleichsberechnungen Tabelle 4.3 Rechenwert
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
    [ini_stress]
        type = ComputeEigenstrainFromGeostaticInitialStress
        eigenstrain_name = 'ini_stress'
        local_coordinate_system = 'ucsInitialStress'
        principal_stress_1 = ${pconf}
        principal_stress_2 = ${pconf}
        principal_stress_3 = ${pconf}
        stress_1_increment_z = '${fparse ${units 2500 kg/m^3 -> ${modelunit_density} } * -0.5 * ${gravitational_acceleration}}' # density * K_0 * gravity
        stress_2_increment_z = '${fparse ${units 2500 kg/m^3 -> ${modelunit_density} } * -0.5 * ${gravitational_acceleration}}' # density * K_0 * gravity
        stress_3_increment_z = '${fparse ${units 2500 kg/m^3 -> ${modelunit_density} } * -1.0 * ${gravitational_acceleration}}' # density * 1.0 * gravity
    []

    # === Mohr Coulomb specific blocks ===
    [elasticity_tensor]
        type = ComputeIsotropicElasticityTensor
        youngs_modulus = '${units 11 GN/m^2 -> ${modelunit_pressure} }'
        poissons_ratio = 0.25
    []
    [tensile]
        type = CappedMohrCoulombStressUpdate
        tensile_strength = ts
        compressive_strength = cs
        cohesion = coh
        friction_angle = angphi
        dilation_angle = angpsi
        smoothing_tol = '${units 0.7 MN/m^2 -> ${modelunit_pressure} }' #0.1*cohesion!
        yield_function_tol = 1E-5 # 1.0E-12
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
        solid_bulk = '${units 7.333 GN/m^2 -> ${modelunit_pressure} }' # K = E / (3 - 6 * nu)
    []
    [permeability]
        type = PorousFlowPermeabilityConst
        permeability = '5e-19 0 0  0 5e-19 0  0 0 5e-19' #permeability of opalinus 
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
    #◙solve_type = 'NEWTON'

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

 
    [Quadrature]
        type = SIMPSON
        order = SECOND
      []
[]

[Outputs]
    exodus = true
    print_linear_residuals = true
[]

[Debug]
    show_var_residual_norms = true
[]