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

function agent_step!(agent, model)
    destino = (10, 2)  # Punto fijo al que perseguir


    if agent.pos == destino
        println("Fantasma llegó al destino en $destino y se queda quieto.")
        return
    end
    camino = bfs(matrix, agent.pos, destino)
    if length(camino) > 1
        siguiente = camino[2]  # primer paso real
        println("Fantasma en $(agent.pos) moviéndose hacia $destino → próximo: $siguiente")
        move_agent!(agent, siguiente, model)
    else
        println("Fantasma en $(agent.pos) no puede avanzar hacia $destino")
    end
end

function vecinos(pos, matrix)
    x, y = pos
    moves = [(0,1), (0,-1), (1,0), (-1,0)]
    vecinos = []
    for (dx, dy) in moves
        nx, ny = x+dx, y+dy
        if 1 <= nx <= size(matrix,1) && 1 <= ny <= size(matrix,2)
            if matrix[nx, ny] == 1
                push!(vecinos, (nx, ny))
            end
        end
    end
    return vecinos
end

function bfs(matrix, start, goal)
    queue = [start]
    came_from = Dict{Tuple{Int64,Int64}, Union{Nothing,Tuple{Int64,Int64}}}()
    came_from[start] = nothing

    while !isempty(queue)
        current = popfirst!(queue)

        if current == goal
            # Reconstruir camino
            path = []
            while current !== nothing
                push!(path, current)
                current = came_from[current]
            end
            reverse!(path)
            return path
        end

        for vecino in vecinos(current, matrix)
            if !haskey(came_from, vecino)
                came_from[vecino] = current
                push!(queue, vecino)
            end
        end
    end
    return []  # No hay camino
end

# Crear el ambiente, modelo y espacio
function initialize_model()
    space = GridSpace((14,17); periodic = false, metric = :chebyshev)
    model = StandardABM(Ghost, space; agent_step!)
    return model
end

model = initialize_model()
a = add_agent!(Ghost, pos=(7, 9), model) # Pos válida