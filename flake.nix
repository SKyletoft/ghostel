{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
		flake-utils.url = "github:numtide/flake-utils";
		ghostty.url = "github:ghostty-org/ghostty/01825411ab2720e47e6902e9464e805bc6a062a1";
	};

	outputs = { self, nixpkgs, flake-utils, ghostty }: flake-utils.lib.eachDefaultSystem(system:
	let pkgs = import nixpkgs { inherit system; };
	in {
		packages.default = pkgs.stdenv.mkDerivation rec {
			pname = "ghostel";
			version = "0.24.0";
			src = ./.;
			nativeBuildInputs = [ pkgs.zig_0_15 ];
			buildInputs = [ ghostty.packages.${system}.libghostty-vt ];
			patchPhase = ''
				sed -i "s|GHOSTTY_NIX_PATH|${ghostty.packages.${system}.libghostty-vt}|g" build.zig
			'';
			buildPhase = ''
				make build
			'';
			installPhase =
				let real-out = "$out/share/emacs/site-lisp/elpa/ghostel-${version}";
				in ''
					mkdir -p ${real-out}
					cp ghostel-module.so ${real-out}
					cp $src/symbols.map ${real-out}
					cp $src/lisp/*.el ${real-out}
					cp -r $src/vendor $src/etc ${real-out}
				'';
		};
	});
}
