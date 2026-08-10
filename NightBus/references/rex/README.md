# Rex walking sprite — exact technical reference

Source block: `$80F2-$81B1` from `RexSideA.skool` (`ultrabolido/skRex`).

The 192-byte block is four prepared 48-byte images; each image is 3 bytes × 16 rows = 24×16 runtime pixels.

| Phase | Bounding box | Filled pixels | Fill of 24×16 container | Fill inside bbox |
|---:|---:|---:|---:|---:|
| 0 | 15×16 | 78 | 20.3% | 32.5% |
| 1 | 16×15 | 80 | 20.8% | 33.3% |
| 2 | 15×15 | 76 | 19.8% | 33.8% |
| 3 | 15×16 | 78 | 20.3% | 32.5% |

The useful observation is not “Rex is 24 pixels wide”. The visible figure is only about 15–16 pixels wide, with roughly two thirds of its bounding box left empty. That negative space is part of why the sprite remains readable.
