# Análisis Numérico (UCSP)

A Lazarus / Free Pascal desktop application written for the Numerical
Analysis / Numerical Methods course at UCSP. It is a small command console with
an expression parser (`fpexprpars`) and a plotting area (TAChart): you type
calls such as `bisec('x^2-2','x',0,2)` and get the result or a graph.

> **BUILD NOT VERIFIED.** Free Pascal and Lazarus are not installed on the
> machine where this README was written, and installing them was out of scope.
> Nothing below has been compiled or run; it is read from the source.

## Methods exposed by the console

Registered in `parsenumerico.pas`:

| Area | Commands |
|---|---|
| Matrices | `sum`, `res`, `mult`, `multReal`, `trans`, `getElement`, `getRow` |
| Bracketing roots | `bisec`, `fpos` (false position) |
| Open roots | `newt` (Newton), `secan` (secant) |
| Systems | `raph` (Newton–Raphson, with `jacobiana.pas`) |
| Intersections | `inter`, `interplus` |
| Integration | `pmedio`, `trap`, `sim1`, `sim3`, `sim1p`, `getarea` |
| ODEs | `euler`, `heun`, `runge4`, `dormand`, `edo` |
| Interpolation / regression | `lag` (Lagrange), `rlineal`, `rexp`, `rln`, `aproxfunc` |
| Taylor series | `tsen`, `tcos`, `texp`, ... |
| Plotting | `func`, `func1`, `func2`, `points`, `pointsfile` |

`RNL/*.csv` are sample point sets (`x,y` per line) for the regression commands,
loaded with `pointsfile('<file>.csv')`.

## Build (untested)

Requires Lazarus with the **TAChartLazarusPkg** and **cmdbox** packages
(both ship with Lazarus).

```bash
lazbuild project1.lpi
./project1
```

or open `project1.lpi` in the Lazarus IDE and press Run. The original build was
done on macOS (i386); output goes to `lib/<cpu>-<os>/`, which is git-ignored.

## Layout

```
project1.lpi / project1.pas   Lazarus project and main program
unit1, unit2, unit4 (.pas/.lfm)   forms: console + plot window
parsenumerico.pas   command registry (maps console names to methods)
class_*.pas         one unit per method family (roots, integrals, ODEs, ...)
matriz*.pas, vector.pas, listfloat.pas, spila.pas   data structures
RNL/                sample CSV data
```

`project1.lpi` still lists `unit3`, `unit5`, `unit6`, `prediccion`,
`taylornumerico` whose sources are not in the repository; the
main program does not `use` them.
