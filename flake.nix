{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    plugins-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects/main";
      flake = false;
    };

    plugins-gitgraph-nvim = {
      url = "github:isakbm/gitgraph.nvim/main";
      flake = false;
    };

    plugins-layers-nvim = {
      url = "github:debugloop/layers.nvim/main";
      flake = false;
    };
  };

  outputs = { nixpkgs, nixCats, ... }@inputs:
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

      categoryDefinitions = { pkgs, ... }: {
        lspsAndRuntimeDeps = {
          general = with pkgs; [
            cabal-install
            clang-tools
            fd
            fourmolu
            gdb
            ghc
            gofumpt
            golangci-lint
            gopls
            haskell-language-server
            lua-language-server
            nil
            nixpkgs-fmt
            nodePackages.prettier
            nodePackages.typescript-language-server
            ormolu
            prettierd
            racket
            ripgrep
            selene
            stylua
            texlab
            tree-sitter
            universal-ctags
            rust-analyzer
          ];
        };

        startupPlugins = {
          general = with pkgs.vimPlugins; [
            catppuccin-nvim
            cmp-conjure
            cmp-nvim-lsp
            cmp-path
            cmp_luasnip
            conform-nvim
            conjure
            eyeliner-nvim
            fidget-nvim
            friendly-snippets
            git-conflict-nvim
            gitsigns-nvim
            haskell-tools-nvim
            lualine-nvim
            luasnip
            nui-nvim
            nvim-cmp
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
            nvim-lint
            nvim-lspconfig
            nvim-nio
            nvim-notify
            nvim-surround
            nvim-treesitter.withAllGrammars
            nvim-web-devicons
            oil-nvim
            plenary-nvim
            rainbow-delimiters-nvim
            telescope-fzf-native-nvim
            telescope-nvim
            telescope-ui-select-nvim
            vim-fugitive
            vim-racket
            vim-racket
            vim-rhubarb
            vim-sexp
            vim-sexp-mappings-for-regular-people
            vim-sleuth
            which-key-nvim

            pkgs.neovimPlugins.gitgraph-nvim
            pkgs.neovimPlugins.layers-nvim
            pkgs.neovimPlugins.treesitter-textobjects
          ];
        };

        sharedLibraries = { };
        environmentVariables = { };
        extraWrapperArgs = { };
      };

      packageDefinitions = {
        nvim = { ... }: {
          settings = {
            suffix-path = true;
            suffix-LD = true;
            wrapRc = true;
            aliases = [ "vim" ];
          };

          categories = {
            general = true;
            have_nerd_font = true;
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
          pkgs = import nixpkgs { inherit system; config = extra_pkg_config; };
        in
        {
          packages = utils.mkAllWithDefault defaultPackage;

          devShells.default = pkgs.mkShell {
            name = defaultPackageName;
            packages = [ defaultPackage ];
          };
        }
      ) //
    (
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
