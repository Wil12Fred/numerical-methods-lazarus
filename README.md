# numerical-methods-lazarus

[![CI](https://github.com/Wil12Fred/numerical-methods-lazarus/actions/workflows/ci.yml/badge.svg)](https://github.com/Wil12Fred/numerical-methods-lazarus/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A Lazarus / Free Pascal desktop console for numerical methods: you type calls
such as `bisec('power(x,2)-2','x',0,2)` into a command box and get the result, or
a plot drawn with TAChart. Root finding, integration, ODEs, interpolation and
regression all go through one expression parser (`fpexprpars`).

## Features

Commands registered in `parsenumerico.pas`:

| Area | Commands |
|---|---|
| Matrices | `sum`, `res`, `mult`, `multReal`, `trans`, `getElement`, `getRow` |
| Bracketing roots | `bisec`, `fpos` (false position) |
| Open roots | `newt` (Newton), `secan` (secant, central difference) |
| Systems | `raph` (Newton–Raphson, with `jacobiana.pas`) |
| Intersections | `inter`, `interplus` |
| Integration | `pmedio`, `trap`, `sim1`, `sim3`, `sim1p`, `getarea` |
| ODEs | `euler`, `heun`, `runge4`, `dormand`, `edo` |
| Interpolation / regression | `lag` (Lagrange), `rlineal`, `rexp`, `rln`, `aproxfunc` |
| Taylor series | `tsen`, `tcos`, `texp` |
| Plotting | `func`, `func1`, `func2`, `points`, `pointsfile` |

`RNL/*.csv` are sample point sets (`x,y` per line) for the regression commands,
loaded with `pointsfile('<file>.csv')`.

## Requirements

- Free Pascal 3.2 and Lazarus 3.0 (what CI uses), with the LCL gtk2 widgetset.
  - Debian/Ubuntu: `sudo apt install fpc lazarus`
  - Arch: `sudo pacman -S fpc lazarus lazarus-gtk2`
- **TAChartLazarusPkg**, which ships with Lazarus.
- **cmdbox**, which does not ship with distribution Lazarus packages. It comes from
  the Lazarus Online Package Manager as `CmdLine.zip`:

  ```bash
  curl -sSfLO https://packages.lazarus-ide.org/CmdLine.zip
  unzip CmdLine.zip -d ~/lazarus-opm
  lazbuild --add-package-link ~/lazarus-opm/CmdLine/cmdbox.lpk
  ```

  (or install "CmdLine" from *Package → Online Package Manager* in the IDE).
- `xvfb` to run the tests on a machine without a display.

## Build

```bash
lazbuild project1.lpi
```

or open `project1.lpi` in the Lazarus IDE and press Run. Unit output goes to
`lib/<cpu>-<os>/` and the binary is `./project1`; both are git-ignored.

## Run

```bash
./project1
```

This opens the console window. Type a command in the box at the bottom, for
example `bisec('power(x,2)-2','x',0,2)` or `func('sin(x)',-3,3)`. CI checks that
the window starts by running it under a virtual display:

```
$ xvfb-run -a timeout 10 ./project1; echo "exit code: $?"
exit code: 124
```

(124 means the program was still running when the timeout fired.)

## Tests

`tests/numerictests.lpr` is a console program that calls the method classes
directly and compares them with known answers. It exits with the number of
failed checks. The units pull in LCL, so it needs a display, and you should always
run it with `xvfb-run` so no window opens on your desktop:

```bash
lazbuild tests/numerictests.lpi
xvfb-run -a ./tests/numerictests
```

Output from the CI run:

```
ok   bisection  x^2-2 on [0,2] = 1.4142456055
ok   false-pos  x^2-2 on [0,2] = 1.4142011834
ok   newton     x^2-2 from 1 = 1.4142135624
ok   newt(...) console from -1 = -1.4142135624
ok   secant     x^2-2 from 1 = 1.4142135624
ok   midpoint   x^3 [0,2] n=1000 = 3.9999980000
ok   trapezoid  x^3 [0,2] n=1000 = 4.0000040000
ok   simpson1/3 x^3 [0,2] n=1000 = 4.0000000000
ok   simpson3/8 x^3 [0,2] n=1000 = 4.0000000000
ok   simpson3/8 x^3 [0,2] n=999  = 4.0000000000
ok   euler      y'=y n=1000 = 2.7169239322
ok   heun       y'=y n=100 = 2.7182368626
ok   runge4     y'=y n=100 = 2.7182818282
ok   lagrange   size after duplicate = 3.0000000000
ok   lagrange   x^2+1 at 1.5 = 3.2500000000
ok   lagrange   x^2+1 at 3 = 10.0000000000
all tests passed
```

What they cover: the roots of x² − 2 (bisection, false position, Newton both
directly and through the `newt(...)` wrapper, secant), ∫₀² x³ dx = 4 (midpoint,
trapezoid, Simpson 1/3, Simpson 3/8, including n divisible by 3), y′ = y with
y(0) = 1 up to x = 1 (Euler, Heun, RK4 against e), and Lagrange interpolation
through x² + 1 with points inserted out of order and a duplicate x.

CI (`.github/workflows/ci.yml`) builds the GUI, smoke-runs it under `xvfb-run`,
and then builds and runs the tests.

## Project layout

```
project1.lpi / project1.pas    Lazarus project and main program
unit1, unit2, unit4 (.pas/.lfm) forms: console + plot window
parsenumerico.pas              command registry (console names -> methods)
parsemath.pas                  expression evaluator used by the methods
class_*.pas                    one unit per method family (roots, integrals, ODEs, ...)
matriz*.pas, vector.pas, listfloat.pas, spila.pas   data structures
tests/                         known-answer test program
RNL/                           sample CSV data
```

## Known limitations

- `bisec`, `fpos`, `newt` and `secan` always evaluate the variable `x`. The
  variable-name argument is registered, but anything other than `x` is ignored.
- `dormand`, `raph`, the regression commands and the plotting commands have no
  automated tests. Only the GUI's start-up is smoke-tested.
- The method objects are created on every call and never freed, so memory grows
  over a long session.
- `project1.lpr` is a leftover second main program. The project builds
  `project1.pas`.
- Number formatting uses `FloatToStr`, so matrix strings built internally
  depend on the locale's decimal separator.

## Background

Written in 2018 for a numerical analysis / numerical methods course at
university.

## License

MIT — see [LICENSE](LICENSE).
