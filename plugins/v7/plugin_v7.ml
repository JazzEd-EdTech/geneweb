open Geneweb.Config
module Gwdb = Geneweb.Gwdb
module Util = Geneweb.Util
module Request = Gwd_lib.Request

open Plugin_v7_lib

let w_base =
  Request.w_base
    ~none:(fun c -> Gwd_lib.Request.incorrect_request c ; true)
let w_person =
  Request.w_person
    ~none:(fun c b -> Gwd_lib.Request.very_unknown c b ; true)

let person_selected conf base p =
  match Util.p_getenv conf.senv "em" with
  | Some "R" -> false
  | Some _ -> false
  | None -> V7_perso.print conf base p ; true

let home conf base : bool =
  if base <> None
  then
    w_base begin fun conf base : bool ->
      if Request.only_special_env conf.env then false
      else w_person begin fun conf base p ->
          match Util.p_getenv conf.env "ptempl" with
          | Some t when Util.p_getenv conf.base_env "ptempl" = Some "yes" -> false
          | _ -> person_selected conf base p
        end conf base
    end conf base
  else false

let l =
  w_base begin fun conf base ->
    Gwdb.dummy_iper
    |> Gwdb.empty_person base
    |> !V7_interp.templ "list" conf base
    |> fun () -> true
    end

let p =
  w_base begin fun conf base -> match Util.p_getenv conf.env "v" with
    | Some v -> V7_some.first_name_print conf base v ; true
    | None -> false
  end

let ps =
  w_base begin fun conf base ->
    V7_place.print_all_places_surnames conf base ;
    true
  end

let ns = "v7"

let _ =
  let aux fn assets conf base =
    Util.add_lang_path assets ;
    fn conf base
  in
  Gwd_lib.GwdPlugin.register ~ns
    [ "", aux home
    ; "L", aux l
    ; "P", aux p
    ; "PS", aux ps
    ]