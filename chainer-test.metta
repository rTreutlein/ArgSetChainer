!(import! &self chainer)

!(bind! &skb (init-kb))
 
!(add-to-kb &skb (() |- ((: a1 (A 1)))))
!(add-to-kb &skb (((: $a (A $v))) |- ((: (b $a) (B $v)))))

!(show-cs &skb)

;!(assertEqualToResult (bc &skb (S Z) (((: a2 (A 2) tv)) |- ((: $p (B $v) $tv)))) 
;                      ((() |- ((: (b a2) (B 2) tv2)))
;                       (() |- ((: (b a1) (B 1) tv2)))))

;!(bind! &cpu (init-kb))
;
;!(add-to-kb &cpu (() |- ((: a1 (A 1) tv1))))
;!(add-to-kb &cpu (() |- ((: a2 (A 2) tv2))))
;
;!(add-to-kb &cpu (((: $a1 (A $v1) $tv1) (: $a2 (A $v2) $tv2) (CPU + ($v1 $v2) $v3)) |- ((: (b $a1 $a2) (B $v3) tv3))))
;
;!(assertEqualToResult (bc &cpu (S Z) (() |- ((: $b (B $v) $btv))))
;   ((() |- ((: (CPU + (2 2)) (CPU 4)) (: (b a2 a2) (B 4)) (: a2 (A 2))))
;    (() |- ((: (CPU + (2 1)) (CPU 3)) (: (b a2 a1) (B 3)) (: a2 (A 2)) (: a1 (A 1))))
;    (() |- ((: (CPU + (1 2)) (CPU 3)) (: (b a1 a2) (B 3)) (: a1 (A 1)) (: a2 (A 2))))
;    (() |- ((: (CPU + (1 1)) (CPU 2)) (: (b a1 a1) (B 2)) (: a1 (A 1))))))

;!(bind! &tv (init-kb))
;
;;!(add-to-kb &tv (((A $atv)) |- ((: (CPU * ($atv 0.5)) (CPU $btv)) (B $btv))))
;;!(add-to-kb &tv (((B $btv)) |- ((: (CPU * ($btv 0.5)) (CPU $ctv)) (C $ctv))))
;
;;!(add-to-kb &tv (() |- ((A 0.5))))
;!(add-to-kb &tv (((A $atv) (Mul $atv 0.5 $btv)) |- ((B $btv))))
;!(add-to-kb &tv (((B $btv) (Mul $btv 0.5 $ctv)) |- ((C $ctv))))
;
;!(add-to-kb &tv (((Mul $a $b $r)) |- ((Mul $b $a $r))))
;
;!(add-to-kb &tv (() |-  ((: (CPU * ($a $b)) (CPU $c)) (Mul $a $b $c))))
;
;
;;!(add-to-kb &tv (((: (CPU * ($a $b)) (CPU $c))) |- ((: (CPU * ($b $a)) (CPU $c)))))
;
;;!(add-to-kb &tv (((: (CPU * ($a $b)) (CPU $ab)) (: (CPU * ($ab $c)) (CPU $abc))) |- ((: (CPU * ($a $c)) (CPU $ac)) (: (CPU * ($ac $b)) (CPU $abc)))))
;
;!(show-cs &tv)
;
;!(bc &tv (S (S Z)) (((A 1)) |- ((B $btv))))
;!(bc &tv (S (S Z)) (((A 1)) |- ((Mul 0.5 1 $ctv) (B $btv))))

;!(bind! &nested (init-kb))
;
;!(add-to-kb &nested (() |- (A)))
;!(add-to-kb &nested (() |- (B)))
;
;!(add-to-kb &nested (() |- ((Implication (∧ (A B)) C))))
;
;!(add-to-kb &nested (((Implication $a $b) $a) |- ($b)))
;
;!(bc &nested (S (S Z)) (() |- (C)))

;;;Some tests
;!(bind! &s (init-kb))
;
;!(add-to-kb &s (((: $a A) (: $b B)) |- ((: (f $a $b) C))))
;!(add-to-kb &s (((: $b B)) |- ((: (f2 a $b) D))))
;!(add-to-kb &s (((: $b B) (: $e E)) |- ((: (f3 a $b $e) F))))
;
;!(add-to-kb &s (() |- ((: a A))))
;!(add-to-kb &s (() |- ((: b B))))
;
;;; Basic type queries
;!(assertEqual (bc &s Z (() |- ((: $a A)))) (() |- ((: a A))))
;!(assertEqual (bc &s Z ($args |- ((: $a A)))) (() |- ((: a A))))
;
;!(assertEqual (bc &s Z (() |- ((: $a A)(: $b B)))) (() |- ((: a A)(: b B))))
;
;!(assertEqual (bc &s (S (S Z)) (() |- ((: $p C))))
;    (() |- ((: (f a b) C) (: a A) (: b B))))
;
;!(assertEqual (bc &s (S (S Z)) (() |- ((: (f a b) $t))))
;    (() |- ((: (f a b) C) (: a A) (: b B))))
;
;;Partial application
;!(assertEqual (bc &s (S (S Z)) (((: $a A)) |- ((: $c C))))
;     (((: $a A)) |- ((: (f $a b) C) (: b B))))
;
;!(assertEqual (bc &s (S Z) (() |- ((: (f $a b) $t))))
;    (() |- ((: (f a b) C) (: a A) (: b B))))
;
;!(assertEqual (bc &s (S (S Z)) (() |- ((: $d D))))
;    (() |- ((: (f2 a b) D) (: b B))))
;
;!(assertEqual (bc &s (S (S Z)) (() |- ((: (f2 a b) $t))))
;    (() |- ((: (f2 a b) D) (: b B))))
;
;!(assertEqual (bc &s (S (S Z)) (((: $e E)) |- ((: $f F))))
;    (((: $e E)) |- ((: (f3 a b $e) F) (: b B))))
;
;!(assertEqual (bc &s (S (S Z)) (((: $e E)) |- ((: (f3 a b $e) $t))))
;    (((: $e E)) |- ((: (f3 a b $e) F) (: b B))))
;
;!(bind! &f1 (init-kb))
;
;!(add-to-kb &f1 (() |- ((: (f1) A))))
;!(add-to-kb &f1 (((: $b B)) |- ((: $a A) (: (f2 $a $b) C))))
;
;!(assertEqual (bc &f1 (S Z) (() |- ((: $a A)))) (() |- ((: (f1) A))))
;
;!(bind! &f2 (init-kb))
;
;!(add-to-kb &f2 (((: $a A)) |- ((: (f1 $a) B))))
;!(add-to-kb &f2 (((: $a A) (: $c C)) |- ((: (f2 $a $c) D))))
;
;!(assertEqual (bc &f2 (S Z) (((: $a A)) |- $type)) (((: $a A)) |- ((: (f1 $a) B))))
;
;!(bind! &f3 (init-kb))
;
;!(add-to-kb &f3 (((: $a A)) |- ((: (f2 $a) B))))
;!(add-to-kb &f3 (((: $z Z)) |- ((: (f2 $a) B))))
;!(add-to-kb &f3 (((: $a A) (: $b B)) |- ((: (f3 $a $b) C))))
;!(add-to-kb &f3 (((: $a A) (: $x X)) |- ((: (ff $a $x) Y))))
;!(add-to-kb &f3 (((: $c C)) |- ((: (f4 $c) D))))
;
;!(assertEqual (bc &f3 (S (S Z)) (((: $a A)) |- ((: $d D))))
;   (((: $a A)) |- ((: (f4 (f3 $a (f2 $a))) D) (: (f3 $a (f2 $a)) C) (: (f2 $a) B))))

;!(bind! &b (init-kb))
;
;!(add-to-kb &b (((: $a A)) |- ((: (ab $a) B))))
;!(add-to-kb &b (((: $b B)) |- ((: (bc $b) C))))
;!(add-to-kb &b (((: $c C)) |- ((: (cd $c) D))))
;!(add-to-kb &b (((: $d D)) |- ((: (de $d) E))))
;!(add-to-kb &b (((: $e E)) |- ((: (ef $e) F))))
;!(add-to-kb &b (((: $f F)) |- ((: (fg $f) G))))
;!(add-to-kb &b (((: $g G)) |- ((: (gh $g) H))))
;
;!(time (bcset &b (fromNumber 3) (((: $a A)) |- ((: $f E)))))
