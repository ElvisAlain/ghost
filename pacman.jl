using Agents # Importa Agents.jl para las funciones StandardABM, GridSpace, add_agent!, etc.

@agent struct Ghost(GridAgent{2}) # 2: Dimensiones
    type::String = "Ghost" # Definir atributo 
end

matrix = [
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 0;
    0 1 0 1 0 0 0 1 1 1 0 1 0 1 0 1 0;
    0 1 1 1 0 1 0 0 0 0 0 1 0 1 1 1 0;
    0 1 0 0 0 1 1 1 1 1 1 1 0 0 0 1 0;
    0 1 0 1 0 1 0 0 0 0 0 1 1 1 0 1 0;
    0 1 1 1 0 1 0 1 1 1 0 1 0 1 0 1 0;
    0 1 0 1 0 1 0 1 1 1 0 1 0 1 0 1 0;
    0 1 0 1 1 1 0 0 1 0 0 1 0 1 1 1 0;
    0 1 0 0 0 1 1 1 1 1 1 1 0 0 0 1 0;
    0 1 1 1 0 1 0 0 0 0 0 1 0 1 1 1 0;
    0 1 0 1 0 1 0 1 1 1 0 0 0 1 0 1 0;
    0 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 0;
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
] # Matriz del laberinto (0: pared, 1: camino)

# Cambia el estado de la figura qu ehay detrás, con bang --> '!'
function agent_step!(agent, model)
    # Posibles movimientos: arriba, abajo, izquierda, derecha
    moves = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    posibles = []
    x, y = agent.pos
    for (dx, dy) in moves
        nx, ny = x + dx, y + dy
        # Verifica que la nueva posición esté dentro de los límites de la matriz
        if 1 <= nx <= size(matrix, 1) && 1 <= ny <= size(matrix, 2)
            # Solo permite moverse a celdas libres (valor 1: camino :D)
            if matrix[nx, ny] == 1
                push!(posibles, (nx, ny))
            end
        end
    end
    # Si hay movimientos posibles, elige uno al azar
    if !isempty(posibles)
        nueva_pos = rand(posibles)
        move_agent!(agent, nueva_pos, model)
    end
end

# Crear el ambiente, modelo y espacio
function initialize_model()
    space = GridSpace((14,17); periodic = false, metric = :chebyshev)
    model = StandardABM(Ghost, space; agent_step!)
    return model
end

model = initialize_model()
a = add_agent!(Ghost, pos=(7, 9), model) # Pos válida