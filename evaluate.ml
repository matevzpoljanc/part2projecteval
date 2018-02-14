open Core_bench
open Core_kernel

open Travelling_salesman
let benchmark = Bench.Test.create_indexed ~name:"Travelling salesman" 
                        (fun x -> Staged.stage @@ fun () -> ignore @@ travelling_salesman @@ generate_graph ~range:10 (x+2))

let () =
     Bench.bench [benchmark ~args:[2;4;6;8]]