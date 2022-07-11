# Jinja template for tex files

This is a nix-flake for  Jiml,  a Python script that renders Jinja templates with data from YAML files.

## build

```
nix build .#
```

## run

```
nix run .# -- -y data.yml -t template.tex -o final.tex
```

