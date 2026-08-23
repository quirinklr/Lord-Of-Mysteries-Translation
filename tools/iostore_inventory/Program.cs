using CUE4Parse.FileProvider;
using CUE4Parse.UE4.Versions;

if (args.Length < 2)
{
    Console.Error.WriteLine("usage: iostore_inventory <Paks directory> <output file>");
    return 2;
}

var paksDirectory = Path.GetFullPath(args[0]);
var outputFile = Path.GetFullPath(args[1]);

var provider = new DefaultFileProvider(
    new DirectoryInfo(paksDirectory),
    SearchOption.TopDirectoryOnly,
    new VersionContainer(EGame.GAME_UE5_7),
    StringComparer.OrdinalIgnoreCase);

provider.Initialize();
Console.WriteLine($"registered_vfs={provider.UnloadedVfs.Count} mounted_before={provider.MountedVfs.Count}");
foreach (var reader in provider.UnloadedVfs)
{
    Console.WriteLine(
        $"vfs path={reader.Path} type={reader.GetType().Name} encrypted={reader.IsEncrypted} "
        + $"directory_index={reader.HasDirectoryIndex} key_guid={reader.EncryptionKeyGuid}");
}
var mounted = provider.Mount();
provider.PostMount();
Console.WriteLine($"mounted_now={mounted} mounted_total={provider.MountedVfs.Count} remaining_unloaded={provider.UnloadedVfs.Count}");

var interestingTokens = new[]
{
    "dialog", "subtitle", "caption", "localization", "language", "stringdb",
    "widget", "text", "talk", "quest", "cinematic", "sequence", "movie"
};

Directory.CreateDirectory(Path.GetDirectoryName(outputFile)!);
await using var stream = File.Create(outputFile);
await using var writer = new StreamWriter(stream, new System.Text.UTF8Encoding(false));

var total = 0;
var interesting = 0;
foreach (var pair in provider.Files.OrderBy(pair => pair.Key, StringComparer.OrdinalIgnoreCase))
{
    total++;
    var path = pair.Key.Replace('\\', '/');
    if (!interestingTokens.Any(token => path.Contains(token, StringComparison.OrdinalIgnoreCase)))
        continue;

    interesting++;
    await writer.WriteLineAsync(path);
}

Console.WriteLine($"mounted_files={total} interesting_files={interesting} output={outputFile}");
return 0;
