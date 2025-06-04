[Mesh]

  # ===== Inactive Block Names =====

  Volume_1_inactive = 'Volume_1_inactive'

  # ===== Object Classes =====

  AllLineElements = ''

  AllPoints = ''

  AllSurfaceElements = 'Boundary_XMax
                        Boundary_XMin
                        Boundary_YMax
                        Boundary_YMin
                        Boundary_ZMax
                        Boundary_ZMin'

  AllVolumeElements = 'Volume_1'

  AllVolumeElements_inactive = 'Volume_1_inactive'

  # ===== Surface Objects =====

  Boundary_XMax = 'Boundary_XMax'

  Boundary_XMin = 'Boundary_XMin'

  Boundary_YMax = 'Boundary_YMax'

  Boundary_YMin = 'Boundary_YMin'

  Boundary_ZMax = 'Boundary_ZMax'

  Boundary_ZMin = 'Boundary_ZMin'

  # ===== Volume Objects =====

  Volume_1 = 'Volume_1'

[]


# Fake users for the variables above
[Functions]
  [FakeUser_Mesh_Volume_1_inactive]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/Volume_1_inactive}
  []
  [FakeUser_Mesh_AllLineElements]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/AllLineElements}
  []
  [FakeUser_Mesh_AllPoints]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/AllPoints}
  []
  [FakeUser_Mesh_AllSurfaceElements]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/AllSurfaceElements}
  []
  [FakeUser_Mesh_AllVolumeElements]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/AllVolumeElements}
  []
  [FakeUser_Mesh_AllVolumeElements_inactive]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/AllVolumeElements_inactive}
  []
  [FakeUser_Mesh_Boundary_XMax]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/Boundary_XMax}
  []
  [FakeUser_Mesh_Boundary_XMin]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/Boundary_XMin}
  []
  [FakeUser_Mesh_Boundary_YMax]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/Boundary_YMax}
  []
  [FakeUser_Mesh_Boundary_YMin]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/Boundary_YMin}
  []
  [FakeUser_Mesh_Boundary_ZMax]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/Boundary_ZMax}
  []
  [FakeUser_Mesh_Boundary_ZMin]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/Boundary_ZMin}
  []
  [FakeUser_Mesh_Volume_1]
    type = ParsedFunction
    expression = 'a'
    symbol_names = 'a'
    symbol_values = '1'
    control_tags = ${Mesh/Volume_1}
  []
[]
