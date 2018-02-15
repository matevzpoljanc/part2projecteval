open Core_bench
open Core_kernel

open Travelling_salesman

let benchmark_normal = Bench.Test.create_indexed ~name:"Travelling salesman" 
                        (fun x -> Staged.stage @@ fun () -> ignore @@ travelling_salesman @@ generate_graph ~range:10 (x))

(* let benchmark_incremental = Bench.Test.create_indexed ~name:"Travelling salesman incremental"
                        (fun n -> Staged.stage @@ fun () -> Travelling_salesman_incremental.number_of_nodes_v)
*)

let () =
    let args = [2;4;6;8] in
    Bench.bench [benchmark_normal ~args:args; ]