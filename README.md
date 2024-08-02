# Nix Templates

---

A collection of templates for application development, supercharged with nix.

---

## Notes

## See Also

- [Nix package search](https://search.nixos.org/packages)
- [NixOS & Flakes book](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/introduction-to-flakes)
- [pre-commit hooks](https://github.com/cachix/git-hooks.nix)
- [nix-environments](https://github.com/nix-community/nix-environments/tree/master)
- [Why nix?](https://fzakaria.com/2024/07/05/learn-nix-the-fun-way.html)

---

# Python package

---

# Developing for python with poetry2nix

There are two seperate devShell environments provided by `flake.nix`: `default`
and `poetry`. The `poetry` environment adds `poetry` to the `$PATH`, so
dependences can be added:

```
$ nix develop .#poetry
$ poetry add opencv-python
```

The development environment is the `default` devShell:

```
$ nix develop .
$ python3
Python 3.12.4 (main, Jun  6 2024, 18:26:44) [GCC 13.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import cv2
>>>
```
