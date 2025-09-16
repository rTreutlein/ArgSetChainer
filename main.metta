!(import! &self chainer)
!(import! &self compiler)

(= (query $kb $depth $query)
   (let ($cquery $stmts) (tracem cq (compileQuery $query))
         (let $NN (collapse (add-to-kb $kb (superpose $stmts)))
            (tracem qbcout (bc $kb $depth $cquery)))))

(= (compileAdd $kb $stmt)
   (add-to-kb $kb (mcompile $stmt)))
