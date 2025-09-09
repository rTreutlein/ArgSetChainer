!(import! &self utils)

(= (addidx $expr $idx)
  (if-decons-expr $expr $head $tail
    (let $nhead ($head $idx)
     (let $ntail (addidx $tail (+ $idx 1))
      (cons-atom $nhead $ntail)))
    $expr))

!(assertEqual (addidx (a b c) 0) ((a 0) (b 1) (c 2)))

!(bind! sqrt (py-atom math.sqrt))

(= (out (: $NNprf $type $NNtv))
  (if-decons-expr $type $head $tail
    (if (not (is-variable $head))
      (case $head
        ((And
          (let $f (\1 ($elem $idx) (superpose ( (((: $prf $type (STV $tvs $tvc)) (CPU sqrt ($tvs) $ntvs)) |- ((: (proj $idx $prf) $elem (STV $ntvs $tvc)))) (out (: $prf $elem $tv))) ))
          (let $idtail (addidx $tail 0)
          ($f (superpose $idtail))))
         )
         (Or
          (let $f (\1 ($elem $idx) (superpose ( (((: $prf $type $tv)) |- ((: (proj $idx $prf) $elem $tv))) (out (: $prf $elem $tv)))))
          (let $idtail (addidx $tail 0)
          ($f (superpose $idtail))))
         )
        ))
      Empty)
    Empty))

;!(out (: prf (Or a b) (STV 1.0 1.0)))

(= (inTemplate $formula $head $tail)
 (let $prms (map $tail (\1 $elem (: $prf $elem $tv)))
  (let $f (\2 ($premises (: $cclprf $ccltype $ccltv)) (: $prfelem $elem $tve)
           (let (($NN1 $NN2 $NN3 $tv) $NNr) (decons-atom $premises)
            ((munion-atom $premises ((: $prfelem $elem $tve) (CPU $formula ($tv $tve) $ntv)))
             (: (cons-atom $prfelem $cclprf) (cons-atom $elem $ccltype) $ntv)
            )))
   (let ((: $fstprf $fstelem $fsttv) $rst) (decons-atom $prms)
    (let ($resNNprms (: $cclprf $ccltype $ccltv)) (foldl $rst (((: $fstprf $fstelem $fsttv)) (: ($fstprf) ($fstelem) $fsttv)) $f)
     (let ($rcclprf $rccltype) ((reverse $cclprf) (reverse $ccltype))
     ($resNNprms |- ((: (cons-atom conjunction $rcclprf) (cons-atom $head $rccltype) $ccltv)))))))))

(= (in (: $prf $type $tv))
   (if-decons-expr $type $head $tail
     (if (not (is-variable $head))
       (case $head
         ((And (superpose ((inTemplate and-formula $head $tail) (in (: $prf (superpose $tail) $tv)))))
          (Or (superpose ((inTemplate or-formula $head $tail) (in (: $prf (superpose $tail) $tv)))))
         ))
         Empty)
     Empty))

;!(in (: prf (And a b) (STV 1.0 1.0)))

(= (extract-vars-ff $accum $elem)
   (if (is-variable $elem) (cons-atom $elem $accum) $accum))

(= (extract-vars $expr) (fold-expr $expr () extract-vars-ff))


(= ((seff $vars) ($idx $atom) $elem) (let $elem (exists $idx $vars) ((+ 1 $idx) $atom)))

(= (subst-exists $a $b)
  (let* (($avars (unique= (extract-vars $a)))
         ($bvars (unique= (extract-vars $b)))
         ($onlyb (unique= (subtraction-atom $bvars $avars)))
         (($_ $res) (foldl $onlyb (0 $b) (seff $avars))))
  $res
))

(= (uPmapf1 $elem)
   (unify $elem (: $prf ($rel $a $b) $itv) (if (and (== $rel Implication) (not (is-variable $rel))) (CPU bc (kb depth ((: $prfa $a (STV 1.0 1.0)) |- (: $prfb $b $itv))) $res) $elem) $elem))

(= (uPmapf2 $elem)
   (unify $elem (: $prfa ($rel $a) (STV $nas $nac)) (if (and (not (is-variable $rel)) (== $rel Not)) (∧ (: $prfa $a (STV $as $ac)) (CPU - (1.0 $as) $nas)) $elem) $elem))

(= (updatePremises $premises)
  (let $temp (map $premises uPmapf1)
   (map $temp uPmapf2)))

(= (post ($premises |- $conclusions))
  (let $npremises (updatePremises $premises)
  (case $conclusions
    ((((: $prf ($relation $a $b) $tv))
       (if (== $relation Implication)
         (superpose ( (post ((munion-atom $npremises ((: $prfa $a $atv) (CPU mp-formula ($atv $tv) $btv))) |- ((: ($prf $prfa) $b $btv))))
                      (out $b)
                      (in $a)
                    ))
         ($npremises |- $conclusions))
     )
     (((: $prf ($relation $a) (STV $strength $confidence)))
       (if (== $relation Not)
          (post ($npremises |- ((: $prf $a (STV (- 1.0 $strength) $confidence)))))
          ($npremises |- $conclusions))
     )
     ($conclusions
      ($npremises |- $conclusions))))))


(= (postQuery ($premises |- $conclusions))
  (let $npremises (updatePremises $premises)
  (case $conclusions
    ((((: $prf ($relation $a $b) $tv))
       (if (lazy-and (not (is-variable $relation)) (== $relation Implication))
         (superpose ( (post ((munion-atom $npremises ((: $prfa $a $atv) (CPU mp-formula ($atv $tv) $btv))) |- ((: ($prf $prfa) $b $btv))))
                      (in $b)
                      (out $a)
                    ))
         ($npremises |- $conclusions))
     )
     (((: $prf ($relation $a) (STV $strength $confidence)))
       (if (lazy-and (== $relation Not) (not (is-variable $relation)))
          (post ($npremises |- ((: $prf $a (STV (- 1.0 $strength) $confidence)))))
          ($npremises |- $conclusions))
     )
     ($conclusions
      ($npremises |- $conclusions))))))

(= (convert $stmt) (unify $stmt (: $prf (WithTV $type $tv)) (: $prf $type $tv) $stmt))

(= (clean $expr)
  (unify $expr ($r $a $b)
    (if (== $r Exists) $b
    (if (== $r Forall) $b
    (if (== $r ForAll) $b
    $expr)))
  $expr))

(= (substitute $expr)
  (if (is-variable $expr)
    VAR
    (if (is-expression $expr)
      (map-atom $expr $elem (substitute $elem))
      $expr)))

(= (mcompile $stmt)
    (let $cleanstmt (convert (map-expr2 $stmt clean))
    (let (: $prf $Type $tv) $cleanstmt
    (if (is-variable $Type)
      Empty
      (case $cleanstmt
        (((: $prf ($relation $a $b) $itv)
          (if (== $relation Implication)
            (let* ( ($nb (subst-exists $a $b))
                    ($na (subst-exists $b $a))
                  )
            (post (superpose ( (((: $prfa $a $atv) (CPU mp-formula ($itv $atv) $btv))
                                |-
                                ((: ($prf $prfa) $nb $btv)))
                                (out (: ($prf $prfa) $nb $btv))
                                (in (: $prfa $a $atv))

                               (((: $prfsb (substitute $b) $btv1)
                                 (: $prfb $b $btv2)
                                 (CPU stv< ($btv1 $btv2) True)
                                 (: $pa (substitute $na) $atv)
                                 (CPU inversion-formula ($atv $btv1 $itv) $nitv)
                                 (CPU mp-formula ($btv2 $nitv) $natv)
                                )
                                |-
                                ((: ((inverted $prf $pa $prfsb) $prfb) $na $natv)))
                                (out (: ((inverted $prf $pa $pb1) $pb2) $na $natv))
                                (in (: $pb2 $b $btv2))
                             ))))
            (post (superpose ( (() |- ($cleanstmt))
                  (out $cleanstmt))))
            ))
         ($cleanstmt
          (post (superpose ( (() |- ($cleanstmt))
                             (out $cleanstmt)
         ))))))))))

(= (compileQuery $stmt)
 (let (: $prf $Type $tv) (tracem pcon (convert (map-expr2 $stmt clean)))
  (if (is-variable $Type)
   ( (() |- ((: $prf $Type $tv))) ())
   (unify $Type ($relation $a $b)
    (if (== $relation Implication)
     ((postQuery (((: $prfa $a (STV 1.0 1.0))) |- ((: $prfb $b $itv))))
      (collapse (postQuery (superpose ( (in (: $prfb $b $btv)) (out (: $prfa $a $atv)) ))))
     )
     ((postQuery (() |- ((: $prf $Type $tv))))
      (collapse (postQuery (in (: $prf $Type $tv))))))
    ((postQuery (() |- ((: $prf $Type $tv))))
     (collapse (postQuery (in (: $prf $Type $tv))))))
  )))


(= (compileAdd $kb $stmt)
   (add-to-kb $kb (mcompile $stmt)))

;!(mcompile (: imlprf (Implication (Or A B) (And C D)) (STV 1.0 1.0)))

;(((: $prfa#65079 (Or A B) $atv#65082) (CPU mp-formula ((STV 1.0 1.0) $atv#65082) $btv#65083)) |- ((: (imlprf $prfa#65079) (And C D) $btv#65083)))
;(((: $prf#77076 (And C D) (STV $tvs#77077 $tvc#77078)) (CPU math.sqrt ($tvs#77077) $ntvs#77079)) |- ((: (proj 0 $prf#77076) C (STV $ntvs#77079 $tvc#77078))))
;(((: $prf#77076 (And C D) (STV $tvs#77077 $tvc#77078)) (CPU math.sqrt ($tvs#77077) $ntvs#77079)) |- ((: (proj 1 $prf#77076) D (STV $ntvs#77079 $tvc#77078))))
;(((: $NN2#79912 A $tv#79908) (: $prf#79909 B $tv#79910) (CPU or-formula ($tv#79908 $tv#79910) $ccltv#78219)) |- ((: (conjunction $NN2#79912 $prf#79909) (Or A B) $ccltv#78219)))
;
;(((: $prfsb#65084 (And C D) $btv1#65085) (: $prfb#65081 (And C D) $btv2#65086) (CPU stv< ($btv1#65085 $btv2#65086) True) (: $pa#65087 (Or A B) $atv#65082) (CPU inversion-formula ($atv#65082 $btv1#65085 (STV 1.0 1.0)) $nitv#65088) (CPU mp-formula ($btv2#65086 $nitv#65088) $natv#65089)) |- ((: ((inverted imlprf $pa#65087 $prfsb#65084) $prfb#65081) (Or A B) $natv#65089)))
;(((: $prf#86425 (Or A B) $tv#86426)) |- ((: (proj 0 $prf#86425) A $tv#86426)))
;(((: $prf#86425 (Or A B) $tv#86426)) |- ((: (proj 1 $prf#86425) B $tv#86426)))
;(((: $fstprf#89085 C $tv#89092) (: $prfelem#89082 D $tv#89088) (CPU and-formula ($tv#89092 $tv#89088) $ccltv#87397)) |- ((: (conjunction $fstprf#89085 $prfelem#89082) (And C D) $ccltv#87397)))
