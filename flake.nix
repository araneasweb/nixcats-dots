{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    plugins-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects/main";
      flake = false;
    };

    gitgraph-nvim = {
      url = "github:isakbm/gitgraph.nvim/main";
      flake = false;
    };

    layers-nvim = {
      url = "github:debugloop/layers.nvim/main";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixCats, ... }@inputs:
    let
      inherit (nixCats) utils;
      luaPath = ./.;
      forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;

      extra_pkg_config = {
        allowUnfree = true;
      };

      dependencyOverlays = [
        (utils.standardPluginOverlay inputs)
      ];

      categoryDefinitions = { pkgs, settings, categories, extra, name, mkPlugin, ... }: {
        lspsAndRuntimeDeps = {
          general = with pkgs; [
            haskell-language-server
            ghc
            cabal-install
            lua-language-server
            nodePackages.typescript-language-server
            rust-analyzer
            gopls
            clang-tools
            texlab
            racket
            ripgrep
            fd
            nil
            tree-sitter
            universal-ctags
            stylua
            gofumpt
            nodePackages.prettier
            prettierd
            nixpkgs-fmt
            fourmolu
            ormolu
            golangci-lint
            selene
            gdb
          ];
        };

        startupPlugins = {
          general = with pkgs.vimPlugins; [
            catppuccin-nvim
            nvim-lspconfig
            nvim-cmp
            cmp-nvim-lsp
            cmp-path
            cmp_luasnip
            luasnip
            friendly-snippets
            haskell-tools-nvim
            conform-nvim
            nvim-lint
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
            nvim-nio
            which-key-nvim
            oil-nvim
            nvim-web-devicons
            telescope-nvim
            telescope-fzf-native-nvim
            telescope-ui-select-nvim
            lualine-nvim
            fidget-nvim
            nvim-notify
            gitsigns-nvim
            git-conflict-nvim
            vim-fugitive
            vim-rhubarb
            vim-sleuth
            nvim-surround
            eyeliner-nvim
            plenary-nvim
            nui-nvim
            nvim-treesitter-context
            vim-racket
            nvim-treesitter.withAllGrammars
            pkgs.neovimPlugins.treesitter-textobjects
          ];
        };

        sharedLibraries = { };

        environmentVariables = { };

        extraWrapperArgs = { };
      };

      packageDefinitions = {
        nvim = { pkgs, name, ... }: {
          settings = {
            suffix-path = true;
            suffix-LD = true;
            wrapRc = true;
            aliases = [ "vim" ];
          };
          categories = {
            general = true;
          };
        };
      };
      defaultPackageName = "nvim";
    in
    forEachSystem
      (system:
        let
          nixCatsBuilder = utils.baseBuilder luaPath
            {
              inherit nixpkgs system dependencyOverlays extra_pkg_config;
            }
            categoryDefinitions
            packageDefinitions;
          defaultPackage = nixCatsBuilder defaultPackageName;
          pkgs = import nixpkgs { inherit system; };
        in
        {
          packages = utils.mkAllWithDefault defaultPackage;
          devShells = {
            default = pkgs.mkShell {
              name = defaultPackageName;
              packages = [ defaultPackage ];
              inputsFrom = [ ];
              shellHook = ''
        '';
            };
          };

        }) // (
      let
        nixosModule = utils.mkNixosModules {
          moduleNamespace = [ defaultPackageName ];
          inherit defaultPackageName dependencyOverlays luaPath
            categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
        };
        homeModule = utils.mkHomeModules {
          moduleNamespace = [ defaultPackageName ];
          inherit defaultPackageName dependencyOverlays luaPath
            categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
        };
      in
      {
        overlays = utils.makeOverlays luaPath
          {
            inherit nixpkgs dependencyOverlays extra_pkg_config;
          }
          categoryDefinitions
          packageDefinitions
          defaultPackageName;

        nixosModules.default = nixosModule;
        homeModules.default = homeModule;

        inherit utils nixosModule homeModule;
        inherit (utils) templates;
      }
    );
}
