unit LauncherSettings;

interface


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$I Definitions.inc}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


const
  LauncherVersion: Byte = 0; // Версия лаунчера, должна совпадать с версией в обвязке

  GlobalSalt: string = 'Соль';

{$IFDEF BEACON}
// Интервал между проверками контрольных сумм во время игры:
  BeaconDelay: Cardinal = 10000; // В миллисекундах!
{$ENDIF}

{$IFDEF EURISTIC_DEFENCE}
// Интервал между поиском параллельно запущенных клиентов:
  EuristicDelay: Cardinal = 15000;
{$ENDIF}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

var
// IP и порт серверной обвязки и Bukkit-сервера:
  PrimaryIP: string = '127.0.0.1'; // Основной IP
  SecondaryIP: string = '127.0.0.1'; // Запасной IP - используется, если не удалось
                                     // присоединиться к основному

  ServerPort: Word = 65533;   // Порт обвязки
  GamePort: string = '25565'; // Порт сервера

// IP и порт распределителя (если используется):
  {$IFDEF MULTISERVER}
  DistributorPrimaryIP: PAnsiChar = '127.0.0.1';
  DistributorSecondaryIP: PAnsiChar = '127.0.0.1';
  DistributorPort: Word = 65534;
  {$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// Адреса скриптов загрузки скинов и плащей на сайте:
  SkinUploadAddress: string = 'http://froggystyle.ru/Minecraft/upload_skin.php';
  CloakUploadAddress: string = 'http://froggystyle.ru/Minecraft/upload_cloak.php';

// Адреса папок со скинами и плащами на сайте:
  SkinDownloadAddress: string = 'http://froggystyle.ru/Minecraft/MinecraftSkins';
  CloakDownloadAddress: string = 'http://froggystyle.ru/Minecraft/MinecraftCloaks';

// Адреса архивов с игрой на сайте:
  ClientAddress: string = 'http://froggystyle.ru/Minecraft/Main.zip';
  AssetsAddress: string = 'http://froggystyle.ru/Minecraft/Assets.zip';

// Адрес лаунчера для автообновления:
  {$IFDEF AUTOUPDATE}
  LauncherAddress: string = 'http://froggystyle.ru/Minecraft/NTLauncher.exe';
  {$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// Это не трогаем:
  ClientTempArchiveName: string = '_$RCVR.bin';
  AssetsTempArchiveName: string = '_$ASTS.bin';

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// Процесс виртуальной машины (java.exe - с консолью, javaw.exe - без консоли):
  JavaApp: string = 'java.exe';

// А это параметры виртуальной машины, их изменять можно:
  JVMParams: string = '';
{
  JVMParams: string = '-server ' +
                      '-D64 ' +
                      '-XX:MaxPermSize=512m ' +
                      '-XX:+UnlockCommercialFeatures ' +
                      '-XX:+UseLargePages ' +
                      '-XX:+AggressiveOpts ' +
                      '-XX:+UseAdaptiveSizePolicy ' +
                      '-XX:+UnlockExperimentalVMOptions ' +
                      '-XX:+UseG1GC ' +
                      '-XX:UseSSE=4 ' +
                      '-XX:+DisableExplicitGC ' +
                      '-XX:MaxGCPauseMillis=100 ' +
                      '-XX:ParallelGCThreads=8 ' +
                      '-DJINTEGRA_NATIVE_MODE ' +
                      '-DJINTEGRA_COINIT_VALUE=0 ' +
                      '-Dsun.io.useCanonCaches=false ' +
                      '-Djline.terminal=jline.UnsupportedTerminal ' +
                      '-XX:ThreadPriorityPolicy=42 ' +
                      '-XX:CompileThreshold=1500 ' +
                      '-XX:+TieredCompilation ' +
                      '-XX:TargetSurvivorRatio=90 ' +
                      '-XX:MaxTenuringThreshold=15 ' +
                      '-XX:+UnlockExperimentalVMOptions ' +
                      '-XX:+UseAdaptiveGCBoundary ' +
                      '-XX:PermSize=1024M ' +
                      '-XX:+UseGCOverheadLimit ' +
                      '-XX:+UseBiasedLocking ' +
                      '-Xnoclassgc ' +
                      '-Xverify:none ' +
                      '-XX:+UseThreadPriorities ' +
                      '-Djava.net.preferIPv4Stack=true ' +
                      '-XX:+UseStringCache ' +
                      '-XX:+OptimizeStringConcat ' +
                      '-XX:+UseFastAccessorMethods ' +
                      '-Xrs ' +
                      '-XX:+UseCompressedOops ';
}

// Путь относительно MainFolder, где будет лежать java(w).exe если
// выставлен флаг использования собственной джавы, скачиваемой в архиве
// вместе с клиентом (Main.zip):
  {$IFDEF CUSTOM_JAVA}
  JavaDir: string = 'java\bin'; // Путь к java(w).exe в %APPDATA%\MainFolder\
  {$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  MainFolder: string = '\.NTLauncher'; // Папка в %APPDATA%: %APPDATA\MainFolder
  RegistryPath: string = 'NTLauncher'; // Название пункта в реестре в ветке HKEY_CURRENT_USER\\Software\\

// Путь к папке с Natives относительно папки MainFolder (%APPDATA%\MainFolder\NativesPath):
  NativesPath: string = 'versions\30FPS (1.7.10)\natives';

// Путь к папке с клиентом относительно MainFolder (%APPDATA%\MainFolder\MineJarPath):
  MineJarFolder: string = 'versions\30FPS (1.7.10)';

// Путь к папке с библиотеками относительно MainFolder (%APPDATA%\MainFolder\LibrariesFolder):
  LibrariesFolder: string = 'libraries'; // Для старых версий (1.5.2 и старше) должен быть пустой строкой!

// Путь к папке с ресурсами (Assets) относительно MainFolder (%APPDATA%\MainFolder\MineJarPath):
  AssetsFolder: string = 'assets';

  GameVersion: string = '1.7.10'; // Версия игры для запуска
  AssetIndex: string = '1.7.10';  // Индекс ресурсов игры

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// Главный класс:

  // Чистый Minecraft до 1.5.2 включительно:
  //MainClass: string = 'net.minecraft.client.Minecraft';

  // Чистый Minecraft, начиная с 1.6:
  //MainClass: string = 'net.minecraft.client.main.Main';

  // Forge, Optifine:
  MainClass: string = 'net.minecraft.launchwrapper.Launch';


// Дополнительные классы для поддержки Forge, LiteLoader, Optifine, GLSL Shaders и т.д.:
// TweakClass'ы можно комбинировать

  // Чистый Minecraft:
  //TweakClass: string = '';

  // Forge:
  //TweakClass: string = '--tweakClass cpw.mods.fml.common.launcher.FMLTweaker';

  // OptiFine без Forge:
  //TweakClass: string = '--tweakClass optifine.OptiFineTweaker';

  // OptiFine + GLSL Shaders без Forge:
  TweakClass: string = '--tweakClass optifine.OptiFineTweaker --tweakClass shadersmodcore.loading.SMCTweaker';

  // LiteLoader:
  //TweakClass: string = '--tweakClass com.mumfrey.liteloader.launch.LiteLoaderTweaker';

  // LiteLoader с Forge:
  //TweakClass: string = '--tweakClass com.mumfrey.liteloader.launch.LiteLoaderTweaker --tweakClass cpw.mods.fml.common.launcher.FMLTweaker';

implementation

end.
