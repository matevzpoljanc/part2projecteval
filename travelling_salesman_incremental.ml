open Incremental_lib

module Inc = Incremental.Make ()
module Var = Inc.Var

let number_of_nodes_v = Var.create 8 
let graph_v = Inc.map (Var.watch number_of_nodes_v) ~f:(fun x -> Travelling_salesman.generate_graph ~range:10 x)

let travelling_salesman_v = Inc.map graph_v ~f:(fun g -> Travelling_salesman.travelling_salesman g)

let result_obs = Inc.observe travelling_salesman_v

let result = Inc.stabilize (); Inc.Observer.value_exn result_obs