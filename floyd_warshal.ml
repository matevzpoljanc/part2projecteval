
let number_of_nodes = 100
let graph = Travelling_salesman.generate_graph number_of_nodes ~range:10

let rec shortestPath i j k = 
    if k = 0 then
        graph.(i).(j)
    else
        min (shortestPath i j (k-1)) (shortestPath i k (k-1) + shortestPath k j (k-1))