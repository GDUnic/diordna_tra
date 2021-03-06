    /*
     * float-to-int
     *
     * We have to clip values to int min/max per the specification.  The
     * expected common case is a "reasonable" value that converts directly
     * to modest integer.  The EABI convert function isn't doing this for us.
     */
    /* unop vA, vB */
    GET_OPB(a3)                            #  a3 <- B
    GET_OPA4(rOBJ)                         #  rOBJ <- A+
    GET_VREG_F(fa0, a3)
    FETCH_ADVANCE_INST(1)                  #  advance rPC, load rINST

    li        t0, INT_MIN_AS_FLOAT
    mtc1      t0, fa1
#ifdef MIPS32REVGE6
    /*
     * TODO: simplify this when the MIPS64R6 emulator
     * supports NAN2008=1.
     */
    cmp.le.s  ft0, fa1, fa0
    GET_INST_OPCODE(t1)                    #  extract opcode from rINST
    bc1nez    ft0, 1f                      #  if INT_MIN <= vB, proceed to truncation
    cmp.eq.s  ft0, fa0, fa0
    selnez.s  fa0, fa1, ft0                #  fa0 = ordered(vB) ? INT_MIN_AS_FLOAT : 0
#else
    c.ole.s   fcc0, fa1, fa0
    GET_INST_OPCODE(t1)                    #  extract opcode from rINST
    bc1t      fcc0, 1f                     #  if INT_MIN <= vB, proceed to truncation
    c.eq.s    fcc0, fa0, fa0
    mtc1      zero, fa0
    movt.s    fa0, fa1, fcc0               #  fa0 = ordered(vB) ? INT_MIN_AS_FLOAT : 0
#endif
1:
    trunc.w.s fa0, fa0
    SET_VREG_F_GOTO(fa0, rOBJ, t1)         #  vA <- result
