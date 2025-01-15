{ lib, ... }:
{
	options.programs.regreet.curserTheme = lib.mkOption {
		type = lib.types.any;
		default = null;
	};
}
