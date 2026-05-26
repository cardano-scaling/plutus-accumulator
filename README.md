## Overview

An accumulator is a cryptographic primitive that allows a prover to succinctly commit to a set of values while being able to provide proofs of (non-)membership. A batch proof is an accumulator proof that can be used to prove (non-)membership of multiple values simultaneously. An accumulator is said to be dynamic if it allows for the addition and removal of elements.

In this repository, we implement such a dynamic universal accumulator as described in [this](https://dl.acm.org/doi/pdf/10.1145/3548606.3560676) paper, using the BLS12-381 pairing curve in plutus V3. Though that paper also describes how one can make this scheme zero-knowledge, this work does not implement this, as the usage of a vector scheme onchain is generally not hiding anyway. If you want to understand the math behind this work, there is [this](https://hackmd.io/@CjIlIbTxRqWOCpWzxuWmkQ/BybaUlSN0) blog.

The main take-away of this exploratory work is that such an accumulator can be very efficient for onchain application where transaction size and memory usage is restricted. The trade-off here is that these costs are moved to the offchain and onchain CPU budget. Besides that, this work is also important for applications which need to assert (non-)membership of multiple elements in the context of one transaction, as batching does not increase the proof size. The size limit of the set is not constrained by the onchain verifier, which makes it ideal for large sets.

In short, this accumulator stores a commitment to a set of elements in one G2 element (96 bytes) and allows for constant size (non)-membership proofs. The membership proofs are also a G2 element (96 bytes) and the non-membership proof requires an extra G1 element (48 bytes).

The core strength of this scheme is that the subtraction of elements from the commitment does not require any more overhead than the required (batched) membership proof. That is because the proof, used for this, is the commitment of an accumulator that represents the old state minus the subset you are proving. Making this scheme ideal for situations where a large state needs to be fanned out in batched stages. The additive case requires a (batched) non-membership proof and a (batched) membership proof for the new accumulator.

## Benchmarks

Some preliminary benchmarks for a batched membership proof of size `n`,

```bash
n membership proofs aggregated verification

    n     Script size             CPU usage               Memory usage
  ----------------------------------------------------------------------
    1     759   (4.6%)      1478304110  (14.8%)           43131   (0.3%)
    2     847   (5.2%)      1563534946  (15.6%)           71366   (0.5%)
    3     935   (5.7%)      1650238538  (16.5%)          105522   (0.8%)
    4    1023   (6.2%)      1738414886  (17.4%)          145599   (1.0%)
    5    1111   (6.8%)      1828063990  (18.3%)          191597   (1.4%)
   10    1553   (9.5%)      2298415151  (23.0%)          510402   (3.6%)
   15    1994  (12.2%)      2805594746  (28.1%)          977232   (7.0%)
   20    2435  (14.9%)      3349593241  (33.5%)         1592087  (11.4%)
   25    2877  (17.6%)      3930410636  (39.3%)         2354967  (16.8%)
   30    3317  (20.2%)      4548046931  (45.5%)         3265872  (23.3%)
   35    3759  (22.9%)      5202502126  (52.0%)         4324802  (30.9%)
   40    4201  (25.6%)      5893776221  (58.9%)         5531757  (39.5%)
   45    4641  (28.3%)      6621864449  (66.2%)         6886737  (49.2%)
   50    5083  (31.0%)      7386776344  (73.9%)         8389742  (59.9%)
   55    5524  (33.7%)      8188507139  (81.9%)        10040772  (71.7%)
   60    5965  (36.4%)      9027056834  (90.3%)        11839827  (84.6%)
   65    6407  (39.1%)      9902425429  (99.0%)        13786907  (98.5%)
   70    6847  (41.8%)     10814612924 (108.1%)        15882012 (113.4%)


n non-membership proofs aggregated verification

    n     Script size             CPU usage               Memory usage
  ----------------------------------------------------------------------
    1     937   (5.7%)      1862401993  (18.6%)           46323   (0.3%)
    2    1025   (6.3%)      1947263675  (19.5%)           74543   (0.5%)
    3    1114   (6.8%)      2033433214  (20.3%)          108675   (0.8%)
    4    1202   (7.3%)      2120910610  (21.2%)          148719   (1.1%)
    5    1290   (7.9%)      2209695863  (22.1%)          194675   (1.4%)
   10    1731  (10.6%)      2673239983  (26.7%)          513135   (3.7%)
   15    2173  (13.3%)      3169493377  (31.7%)          979423   (7.0%)
   20    2614  (16.0%)      3698474702  (37.0%)         1593578  (11.4%)
   25    3055  (18.6%)      4260188776  (42.6%)         2355611  (16.8%)
   30    3496  (21.3%)      4854659791  (48.5%)         3265573  (23.3%)
   35    3938  (24.0%)      5482984591  (54.8%)         4323458  (30.9%)
   40    4379  (26.7%)      6150007491  (61.5%)         5529336  (39.5%)
   45    4820  (29.4%)      6854298358  (68.5%)         6883197  (49.2%)
   50    5261  (32.1%)      7595813554  (76.0%)         8385020  (59.9%)
   55    5703  (34.8%)      8374374176  (83.7%)        10034811  (71.7%)
   60    6144  (37.5%)      9189636279  (91.9%)        11832560  (84.5%)
   65    6585  (40.2%)     10041623409 (100.4%)        13778265  (98.4%)
   70    7026  (42.9%)     10930220221 (109.3%)        15871926 (113.4%)
```

These percentages are given in comparison against the mainnet parameters. You can run the benchmark via

```bash
nix develop github:input-output-hk/devx#ghc96-iog
cabal run plutus-accumulator:bench
```
