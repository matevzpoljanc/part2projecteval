let (>>=) = Lwt.bind

module MemoResult = struct
    module AO = Irmin_mem.AO(Irmin.Hash.SHA1)(Tc.String)
    exception VauleNotFoundInRW
    exception ValueNotFoundInAO
    module Key = struct
        include Tc.String
        let to_hum t = match Ezjsonm.decode_string (to_json t) with
            | Some s -> s
            | None -> raise (Ezjsonm.Parse_error ((to_json t), "Invalid arguments" ))
        let of_hum s = of_json (Ezjsonm.from_string s)
    end

    module RW = Irmin_mem.RW(Key)(Irmin.Hash.SHA1)

    type t = {table_rw: RW.t; table_ao: AO.t}
    let create () =
        let config = Irmin_git.config () in
        AO.create config >>= fun ao_t ->
        RW.create config >>= fun rw_t ->
        Lwt.return {table_rw = rw_t; table_ao = ao_t}

    (* Use Marshal module to provide polymorphism keys and values *)
    let find t key = RW.read t.table_rw (Marshal.to_string key []) >>= 
        function None -> raise VauleNotFoundInRW
            |(Some ao_key) -> AO.read t.table_ao ao_key >>= 
                function None -> raise ValueNotFoundInAO
                    | Some v -> Lwt.return (Marshal.from_string v 0)
    let insert t key value = AO.add t.table_ao (Marshal.to_string value []) >>= fun k ->
        RW.update t.table_rw (Marshal.to_string key []) k
    
    let find_or_add t key ~default = 
        let s_key = Marshal.to_string key [] in 
        RW.read t.table_rw s_key >>=
        function None -> 
            let value =  default () in
             insert t s_key (Marshal.to_string value []) >>= fun () -> Lwt.return value
        | Some _ -> find t key
end

