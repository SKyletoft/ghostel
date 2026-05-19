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
			version = "0.27.0";
			src = pkgs.fetchFromGitHub {
				owner = "dakra";
				repo = "ghostel";
				rev = "v${version}";
				hash = "sha256-Hr/Pd5g9ckXKWh/NMYfRpm5es+ap3D+q4Bk7FdFotkU=";
			};
			patches = [
				./patches/build-zig.patch
				./patches/build-zig-zon.patch
			];
			nativeBuildInputs = [ pkgs.zig_0_15 ];
			buildInputs = [ ghostty.packages.${system}.libghostty-vt ];
			postPatch = ''
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
