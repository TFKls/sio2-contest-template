# Package templates
This directory contains the package templates used by the `./new-package.sh` script. While the existing templates are described in the main `README` file,
below we describe the template format, to help with creating new templates.

## Preprocessing
The following describes the current preprocessing done by the `./new-package.sh`
script when creating a new package from a template.
Firstly the script creates a fresh directory, referenced below as the work
directory (not to be confused with the process' working directory).

Afterwards the script applies firstly the template and then the extras specified
by the user. A template's application follows as described below:

- If the `_extend` file is present in the directory, firstly apply the templates
  under `_templates/$line` for each line in the `_extend` file. Note that these
  must create an acyclic graph, or the script will crash. The script might also
  crash, so be aware of such a possibility
- Copy the template's directory to a temporary directory, dereferencing any
  symbolic links encountered.
- Merge the temporary directory into the work directory as described below
  under the *Directory merging* section.
- Substitute all files ending with one @ sign, as described below
  under the *Template substitution* section.

## Directory merging
The directory merging procedure takes two directories (below referred to as
source and destination) and recursively moves the contents of one into the
other. The procedure is described as follows:

- For each non-hidden file `$source/$file`, move the file into `$destination/$file`,
  if the destination location is not already a file or directory. Otherwise exit
  with an error.
- For each non-hidden directory `$source/$dir`, create the directory
  `$destination/$dir`, and call the merging procedure recursively on `$source/$dir`
  and `$destination/$dir`. If the destination directory already exists, do not fail
  and call recursively on the existing directory. If the destination location is a
  file, exist with an error.
- Remove the now empty `$source` directory

To include hidden files and directories, rename the file accordingly during the
template substitution section. They aren't included to allow for `.gitkeep` and
`.gitignore` files to work properly, and to ensure they are easily visible in
the template directories.

## Template substitution
When a filename ends with an at-sign `@`, it is processed by the substitution engine.
The expected syntax of a templated file (e.g. named `example@` is as follows):
```
@[mode] [name]
| ...
| shell_script
| ...
@
...
content
...
```
The script then takes the content, and passes it to the script via the
standard input, saving the resulting standard output into the `name` file.

If `name` is not set, the result is saved to the filename without the at-sign
(i.e. `example` in our case). Otherwise, it is saved as the result of the
shell expansion of the `name` field, relative to the file's directory.

The mode describes what to do in case the result file already exists.
The accepted modes are as follows:

- `fail` (default) will halt the templating process if the file already exists
- `override` overrides the existing file with the pipeline's result
- `append` appends the pipeline's result to the file, if it exists
- `transform` passes the existing file's contents through the pipeline,
  instead of this file's content, and saves back the result
- `nothing` does nothing if the file exists, ignoring the pipeline and content
- `[mode]!` acts the same as `[mode]`, except it will also fail if the file
  doesn't exist (e.g. `fail!` always fails)
- `transform?` is a special case, it will transform the file with the pipeline
  if it exists, or otherwise create a file with it's raw, untransformed content

If the first line doesn't begin with `@`, it will be defaulted to `@fail`.
Any character other than `@|`, including spaces, starts the content block,
so the ending at-sign is often unnecessary (unless the file contents should begin 
with either of the special characters).
