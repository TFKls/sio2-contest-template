# A SIO2 contest's packageset
*Run `./new-package.sh` before the first commit! (no need to create a package, just run and exit)*

```
❌ - To do
⌛ - To verify
✅ - Done
```
| Id  | State | Package name | Old name |
|-----|-------|--------------|----------|

## Creating new packages
To create a package, run [`./new-package.sh`](./new-package.sh) and enter the required data.
You may want to run it as `sh -x ./new-package.sh`, if you want to trace the script's execution.

The packages are created from a template located under _templates, with the following ones available:
| Name | Description |
|------|-------------|
| standard | TODO |

The following libraries are also available to be included as :
| Name | Description |
|------|-------------|
| oilib | TODO |
| testlib | TODO |

## Repository conventions
When running `./new-package.sh`, multiple **`githooks(5)`** are installed in the local `git` configuration.
The hooks are located under [`./.githooks/`](./.githooks/) and enforce the following:
* All commits must be named `<id>: <desc>`, where `<id>` is an identifier
  of an new/existing package or the literal `*` when making global changes.


## Package conventions
Package tests are named as follows:
```
- zad1ocen.in (included in statement)
- zad2ocen.in
- zad3ocen.in
- zad1a.in
- zad1b.in
- zad2a.in
- zad2b.in
- zad2c.in
```

Package solutions are named as follows:
```
- zad.cpp (model solution)
- zad1.cpp (other correct solution)
- zadb1.cpp (wrong solutions...)
- zadb2.cpp (also partial solutions)
- zads1.cpp (too slow solutions)
```

## `standard` template makefile cheatsheet

## References


