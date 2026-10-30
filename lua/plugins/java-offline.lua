-- ============================================================
--  jdtls (LSP Java de Neovim) 100% HORS-LIGNE — projets Gradle
--  sans wrapper, importés avec le Gradle installé sur ce PC.
--
--  Pourquoi ce fichier ?
--    Par défaut, jdtls (Buildship) utilise le wrapper Gradle du
--    projet et télécharge la distribution pointée. Derrière le proxy
--    (403 sur tout téléchargement), l'import échoue. Ces réglages :
--      1. désactivent l'usage du wrapper,
--      2. imposent le Gradle LOCAL du PC (scoop, 9.8.0),
--      3. imposent le JDK 21 local pour le daemon Gradle,
--      4. pointent le cache sur le GRADLE_USER_HOME du PC
--         (Guava/JUnit déjà en cache → résolution --offline),
--      5. activent le mode offline pour l'import/synchronisation.
--
--  ⚠ JVM du SERVEUR jdtls (changement du 30/10/2026) :
--    jdtls 1.63.0 (Mason, snapshot du 19/10/2026) embarque des bundles
--    Eclipse 2026-09 qui exigent Java >= 25 au démarrage. Lancé sur le
--    JDK 21/22 (ex-JAVA_HOME), on obtient « BundleException …
--    Require-Capability: osgi.ee … JavaSE 25 » et le serveur ne démarre
--    pas du tout. Le serveur est donc lancé sur le JDK 27 scoop via
--    --java-executable, indépendamment de $JAVA_HOME. Le PROJET, lui,
--    reste compilé et exécuté sur le JDK 21 (runtimes ci-dessous) :
--    seule la JVM qui héberge le serveur change.
--
--  ⚠ DÉBOGAGE DAP (correction du 30/10/2026, 3e passe) :
--    Le glob de l'extra LazyVim `share/java-test/*.jar` passe des jars
--    qui font ÉCHOUER la transaction « Load bundle list » de jdtls :
--    • runner-jar-with-dependencies.jar et jacocoagent.jar : non-OSGi ;
--    • org.objectweb.asm_<version>.jar : doublon EXACT de l'asm 9.10.1
--      déjà embarqué dans jdtls ;
--    • com.microsoft.java.test.plugin-<version>.jar : doublon du jar
--      non versionné (même Bundle-SymbolicName ET même version 0.43.1).
--    ⚠ 3e passe : asm.commons_<v> et asm.tree_<v> ne sont PAS des
--    doublons (jdtls n'embarque que l'asm de base) et org.jacoco.core
--    les EXIGE — les retirer faisait échouer jacoco PUIS test.plugin,
--    donc « Failed to load extension bundles » PERSISTAIT → provider
--    Gradle (org.eclipse.buildship.core.classpathprovider) introuvable
--    → resolveClasspath échoue → F5 cassé. On ne retire QUE les 3 cats.
--    ci-dessus. De plus, -configuration/-data sont désormais suffixés
--    d'un hash du root_dir : les copies Desktop et matisse_fred de
--    matisse_IU ne partagent plus le même workspace Eclipse.
--    Après ce changement : purger %LOCALAPPDATA%\Temp\nvim\jdtls.
--
--  Installation (LazyVim) : exécuter install-nvim-config.ps1 (copie ce
--  fichier dans %LOCALAPPDATA%\nvim\lua\plugins\java-offline.lua), puis
--  redémarrer Neovim. Désinstallation : le supprimer.
-- ============================================================
-- Hash court et déterministe d'une chaîne (djb2, 8 chiffres hexa) :
-- rend uniques les dossiers -configuration/-data par root_dir.
-- (vim.fn.sha1 n'existe pas dans Neovim ; arithmétique pure en 64 bits
--  exacts → reproductible sur toutes les versions de Lua.)
local function djb2_hex(s)
  local h = 5381
  for i = 1, #s do
    h = (h * 33 + s:byte(i)) % 0x100000000
  end
  return string.format("%08x", h)
end

return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      -- Tout est déjà installé sur ce PC → rien à télécharger.
      local java_home = "C:/Users/ftarroux/scoop/apps/openjdk21/current"
      local gradle_home = "C:/Users/ftarroux/scoop/apps/gradle/current"
      local gradle_user_home = "C:/Users/ftarroux/scoop/apps/gradle/current/.gradle"

      -- JDK 27 scoop : JVM qui exécute le SERVEUR jdtls (1.63.0 exige
      -- Java >= 25 au démarrage — le JDK 21 de $JAVA_HOME ne suffit plus).
      -- Chemin sans espaces → passage sûr à travers le batch jdtls.CMD de
      -- Mason. Priorité du launcher : --java-executable > $JAVA_HOME.
      local server_jvm = "C:/Users/ftarroux/scoop/apps/openjdk27/current/bin/java.exe"
      opts.cmd = vim.list_extend(opts.cmd or { vim.fn.exepath("jdtls") }, {
        "--java-executable",
        server_jvm,
      })

      local settings = {
        java = {
          configuration = {
            runtimes = {
              { name = "JavaSE-21", path = java_home, default = true },
            },
          },
          import = {
            gradle = {
              enabled = true,
              -- 1) Ignorer le wrapper du projet : sans ceci, Buildship
              --    tenterait de télécharger une distribution Gradle.
              wrapper = { enabled = false },
              -- 2) Gradle LOCAL (scoop) : le daemon part de l'installation
              --    du PC, aucune distribution n'est téléchargée.
              home = gradle_home,
              -- 3) JVM du daemon Gradle : JDK 21 local.
              java = { home = java_home },
              -- 4) Cache local des dépendances (Guava, JUnit…).
              user = { home = gradle_user_home },
              -- 5) Import/synchronisation en mode --offline.
              offline = { enabled = true },
              -- ⚠ Ne PAS définir `version` : jdtls la téléchargerait
              --    depuis services.gradle.org.
            },
          },
        },
      }

      -- Canal 1 : workspace/didChangeConfiguration (géré par nvim-jdtls).
      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, settings)
      -- Canal 2 : initializationOptions.settings (natif jdtls) — appliqué
      -- AVANT le premier import Gradle, ce qui évite toute course avec
      -- l'import initial du workspace. L'extra LazyVim construisant
      -- `init_options` ({ bundles = … }) dans son propre `config` puis
      -- appliquant `opts.jdtls` PAR-DESSUS via `extend_or_override`, on
      -- passe ici une FONCTION : elle reçoit la config finale et la
      -- modifie en place (aucun résidu de fusion profonde de listes).
      opts.jdtls = function(config)
        config.init_options = config.init_options or {}
        config.init_options.settings = settings

        -- ⚠ Correction DAP (30/10/2026, 3e passe) : filtrage des bundles
        -- OSGi. L'extra LazyVim passe TOUT `share/java-test/`. On retire
        -- UNIQUEMENT ce qui casse la transaction « Load bundle list » :
        --   • runner-jar-with-dependencies.jar et jacocoagent.jar :
        --     jars NON-OSGi (fichiers d'exécution des tests, pas des
        --     bundles ; le plugin java-test les retrouve sur disque) ;
        --   • org.objectweb.asm_<v>.jar : doublon EXACT de l'asm 9.10.1
        --     de jdtls. ⚠ asm.commons_<v> et asm.tree_<v> sont au
        --     contraire NÉCESSAIRES (org.jacoco.core les exige, jdtls
        --     ne les fournit pas) ;
        --   • com.microsoft.java.test.plugin-<version>.jar : doublon du
        --     jar non versionné.
        -- Tant qu'UN seul bundle échoue, jdt.ls abandonne et le provider
        -- Gradle org.eclipse.buildship.core.classpathprovider devient
        -- introuvable → resolveClasspath échoue → F5 cassé.
        if config.init_options.bundles then
          config.init_options.bundles = vim.tbl_filter(function(path)
            local name = vim.fn.fnamemodify(path, ":t")
            if name:match("^org%.objectweb%.asm_%d") then
              -- asm de BASE uniquement (asm_<v>.jar) : doublon exact de
              -- l'asm 9.10.1 embarqué dans jdtls. Le motif ne matche NI
              -- asm.commons_<v> NI asm.tree_<v>, qui doivent RESTER :
              -- org.jacoco.core les exige (Import-Package) et jdtls ne
              -- les embarque pas — sans eux, jacoco échoue, puis
              -- test.plugin, puis « Load bundle list » entier.
              return false
            end
            if name:find("runner%-jar%-with%-dependencies", 1, false) then
              return false -- jar du runner : non-OSGi (trouvé sur disque à l'exécution)
            end
            if name == "jacocoagent.jar" then
              return false -- agent JaCoCo : non-OSGi (utilisé via -javaagent)
            end
            if name:match("^com%.microsoft%.java%.test%.plugin%-%d") then
              return false -- doublon versionné du jar non versionné
            end
            return true
          end, config.init_options.bundles)
        end

        -- ⚠ Dossiers -configuration/-data UNIQUES par root_dir (30/10/2026).
        -- L'extra LazyVim les nomme d'après le simple basename du projet :
        -- la copie Desktop de matisse_IU ET celle de matisse_fred mapperait
        -- au même dossier %LOCALAPPDATA%\Temp\nvim\jdtls\matisse_IU\ → même
        -- workspace Eclipse partagé (conflit de nom de projet, verrou
        -- .metadata si deux Neovim ouverts). On suffixe d'un hash court du
        -- chemin complet du root_dir, en conservant config/ et workspace/.
        local islist = vim.islist or vim.tbl_islist
        if config.root_dir and islist(config.cmd) then
          local hash = djb2_hex(config.root_dir):sub(1, 8)
          local base = vim.fs.basename(config.root_dir) or "project"
          for i = 1, #config.cmd - 1 do
            local flag = config.cmd[i]
            if flag == "-configuration" or flag == "-data" then
              local arg = config.cmd[i + 1]
              local leaf = vim.fs.basename(arg)
              local top = vim.fs.dirname(vim.fs.dirname(arg))
                or (vim.fn.stdpath("cache") .. "/jdtls")
              if leaf and top then
                config.cmd[i + 1] = top .. "/" .. base .. "-" .. hash .. "/" .. leaf
              end
            end
          end
        end

        return config
      end
      return opts
    end,
  },
}
