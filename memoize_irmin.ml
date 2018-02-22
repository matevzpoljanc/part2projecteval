let new_function_id = Memoize.new_function_id

module IrminHashTbl = Memo_result.MemoResult

let (>>=) = Lwt.bind


let m = Lwt_main.run (IrminHashTbl.create ())

let memoize (type a) (type b) (f:a->b): a->b =
  let f_id = new_function_id () in
  let g x =
    Lwt_main.run @@ IrminHashTbl.find_or_add m (f_id,x) ~default:(fun () -> (f x)) in
  g
  ;;

let memoize2 (type a) (type b) (type c) (f:a->b -> c): a->b->c =
  let f_id = new_function_id () in
  let g x0 x1 =
    Lwt_main.run @@ IrminHashTbl.find_or_add m (f_id,x0,x1) ~default:(fun () -> (f x0 x1)) in
  g
  ;;
