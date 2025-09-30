using Agents # Importa Agents.jl para las funciones StandardABM, GridSpace, add_agent!, etc.

@agent struct Ghost(GridAgent{2}) # 2: Dimensiones
    type::String = "Ghost" # Definir atributo 
end

# Cambia el estado de la figura qu ehay detrás, con bang --> '!'
function agent_step!(agent, model)
    randomwalk!(agent, model)
end

# Crear el ambiente, modelo y espacio
function initialize_model()
    space = GridSpace((5,5); periodic = false, metric = :chebyshev) # Agente en grid (5x5) | Periodic: ciclo del pacaman (transportacion) | Metrica Manhattan din diagonales, rodear
    model = StandardABM(Ghost, space; agent_step!) # Qué tipo de agente | Espacio Grid | Función que permite evolucionar el estado de los agentes 
    return model
end

model = initialize_model()
a = add_agent!(Ghost, pos=(3, 3), model) # Añadir agente al modelo | Posición (3,3)