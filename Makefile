all:
	nix build

update:
	nix flake update

test:
	nix flake check
	nix run
