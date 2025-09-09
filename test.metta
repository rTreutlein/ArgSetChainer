
!(pragma! exec skip)

!(import! &self main)
;!(import! &self utils)

!(pragma! exec true)

;!(hyperpose ((+ 1 1) (+ 2 2)))

!(bind! &kb (init-kb))

;!(compileAdd &kb (: fact1 (A a) (STV 1.0 1.0)))
;!(compileAdd &kb (: fact2 (A b) (STV 1.0 1.0)))
;!(compileAdd &kb (: fact3 (A c) (STV 1.0 1.0)))
;
;!(compileAdd &kb (: fact4 (B a) (STV 1.0 1.0)))
;!(compileAdd &kb (: fact5 (B b) (STV 1.0 1.0)))
;!(compileAdd &kb (: fact6 (B c) (STV 1.0 1.0)))
;
;!(add-to-kb &kb (((CPU == ($a $b) False)) |- ((: not_eq (NEQ $a $b) (STV 1.0 1.0)))))

;!(query &kb (fromNumber 3) (: $prf (And (A $a1) (A $a2) (B $a1) (B $a2)) $tv))

;!(query &kb (fromNumber 3) (: $prf (And (A $a1) (A $a2) (NEQ $a1 $a2) (B $a1) (B $a2)) $tv))


!(compileAdd &kb (: fact1 (Eat ate) (STV 1.0 1.0)))
!(compileAdd &kb (: fact2 (ate tom apple) (STV 1.0 1.0)))

!(query &kb (fromNumber 3) (: $prf (And ($pred tom apple) (Eat $pred)) $tv))
